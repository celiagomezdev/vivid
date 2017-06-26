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

class MapViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    var googleMap: GMSMapView?
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //MARK: Initial position when no user location
        
        let camera = GMSCameraPosition.camera(withLatitude: 52.520736, longitude: 13.409423, zoom: 12)
        googleMap = GMSMapView.map(withFrame: mapView.frame, camera: camera)
        self.mapView = googleMap
        self.view.addSubview(mapView!)
        self.view.addSubview(searchBar)
        
        let initialLocation = CLLocationCoordinate2DMake(52.520736, 13.409423)
        let marker = GMSMarker(position: initialLocation)
        marker.title = "Berlin"
        marker.map = mapView
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.isHidden = true
    }
    
    //MARK: Simple search button
    
    @IBAction func search(_ sender: Any) {
        if searchBar.isHidden {
            searchBar.isHidden = false
        } else {
            searchBar.isHidden = true
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
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        locationManager.stopUpdatingLocation()
            
        }
    }
}


