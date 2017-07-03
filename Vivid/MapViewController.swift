//
//  MapViewController.swift
//  Vivid
//
//  Created by Celia Gómez de Villavedón on 23/06/2017.
//  Copyright © 2017 Celia Gómez de Villavedón Pedrosa. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces
import GooglePlacePicker
import MapKit
import SearchTextField


class MapViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var mySearchTextField: SearchTextField!
    
    // MARK: Properties
    
    let locationManager = CLLocationManager()
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    
   
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        mySearchTextField.isHidden = true
        //MARK: Call initianLocation method when user disable authorized location
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()

    }
    
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    func initialLocation() {
        let camera = GMSCameraPosition.camera(withLatitude: 52.520736, longitude: 13.409423, zoom: 8)
        self.mapView.camera = camera
        
        let initialLocation = CLLocationCoordinate2DMake(52.520736, 13.409423)
        let marker = GMSMarker(position: initialLocation)
        marker.title = "Berlin"
        marker.map = mapView
        
    }
    
    func searchAutocomplete() {
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        let northEastBoundsCorner = CLLocationCoordinate2D(latitude: 52.650385,
                                                           longitude: 13.730843)
        let southWestBoundsCorner = CLLocationCoordinate2D(latitude: 52.390954,
                                                           longitude: 13.111097)
        let bounds = GMSCoordinateBounds(coordinate: northEastBoundsCorner,
                                         coordinate: southWestBoundsCorner)

        resultsViewController?.autocompleteBounds = bounds
        
        let filter = GMSAutocompleteFilter()
        filter.type = .region
       
        filter.country = "de"
        resultsViewController?.autocompleteFilter = filter
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.hidesNavigationBarDuringPresentation = false
        
  
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true

    }

    //MARK: Simple search button
    
    @IBAction func search(_ sender: Any) {
        mySearchTextField.filterStrings(["Neukölln", "Kreuzberg", "Mitte"])
        mySearchTextField.theme.font = UIFont.systemFont(ofSize:14)
        mySearchTextField.highlightAttributes = [NSFontAttributeName:UIFont.boldSystemFont(ofSize:14)]
        if mySearchTextField.isHidden {
           mySearchTextField.isHidden = false
        } else {
            mySearchTextField.isHidden = true
        }
    }
}

//MARK: Get user location

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        //TODO: If user disable location manually, ask again with an alert (only once)
        
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        } else {
            initialLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        locationManager.stopUpdatingLocation()
            
        }
    }
}

// Handle the user's selection.
extension MapViewController: GMSAutocompleteResultsViewControllerDelegate {
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // Do something with the selected place.
        print("Place name: \(place.name)")
        print("Place address: \(String(describing: place.formattedAddress))")
        print("Place attributions: \(String(describing: place.attributions))")
        print("Place coordinates: \(String(describing: place.coordinate))")
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}



