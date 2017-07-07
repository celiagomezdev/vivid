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


class MapViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var mapView: GMSMapView!

    
    // MARK: Properties
    
    let locationManager = CLLocationManager()
    var userLocation: String?
    

    // MARK: Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //MARK: Call initianLocation method when user disable authorized location
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()

    }
    
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        storeUserLocation()
 
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func initialLocation() {
        let camera = GMSCameraPosition.camera(withLatitude: 52.520736, longitude: 13.409423, zoom: 8)
        self.mapView.camera = camera
        
        let initialLocation = CLLocationCoordinate2DMake(52.520736, 13.409423)
        let marker = GMSMarker(position: initialLocation)
        marker.title = "Berlin"
        marker.map = mapView
        
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
            
            //Save current lat long
            UserDefaults.standard.set(location.coordinate.latitude, forKey: "LAT")
            UserDefaults.standard.set(location.coordinate.longitude, forKey: "LON")
            UserDefaults().synchronize()
            
            locationManager.stopUpdatingLocation()
        }
    }
    
//    func storeUserLocation() {
//        
//        //Access user Location LAT & LON from User Defaults
// 
//        let coordinate =  CLLocationCoordinate2D(latitude: UserDefaults.standard.value(forKey: "LAT") as! CLLocationDegrees, longitude: UserDefaults.standard.value(forKey: "LON") as! CLLocationDegrees)
//        
//        userLocation = "\(coordinate.latitude), \(coordinate.longitude)"
//        print("userLocation is: \((userLocation) ?? "No user Location")")
//
//    }
}



