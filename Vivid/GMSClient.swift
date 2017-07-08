//
//  GMSClient.swift
//  Vivid
//
//  Created by Celia Gómez de Villavedón on 03/07/2017.
//  Copyright © 2017 Celia Gómez de Villavedón Pedrosa. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces
import GooglePlacePicker
import MapKit

class GMSClient: NSObject {
    
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> GMSClient {
        struct Singleton {
            static var sharedInstance = GMSClient()
        }
        return Singleton.sharedInstance
    }
}

//MARK: Location helper methods

extension GMSClient: CLLocationManagerDelegate {
    
    //MARK: Initial Location: Berlin
    
    func initialLocation(_ map: GMSMapView) {
        let camera = GMSCameraPosition.camera(withLatitude: 52.520736, longitude: 13.409423, zoom: 8)
        map.camera = camera
        
        let initialLocation = CLLocationCoordinate2DMake(52.520736, 13.409423)
        let marker = GMSMarker(position: initialLocation)
        marker.title = "Berlin"
        marker.map = map
        
    }

    
    //MARK: Get user location
    
    func getUserLocation(_ map: GMSMapView) {
  
        let locationManager = CLLocationManager()
        var userLocation: String?
       
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            
            //TODO: If user disable location manually, ask again with an alert (only once)
            
            if status == .authorizedWhenInUse {
                locationManager.startUpdatingLocation()
                
                map.isMyLocationEnabled = true
                map.settings.myLocationButton = true
            } else {
                initialLocation(map)
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            
            if let location = locations.first {
                
                map.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
                
                locationManager.stopUpdatingLocation()
                
                //Store User Location
                userLocation = "\(location.coordinate.latitude), \(location.coordinate.longitude)"
                print("userLocation is: \((userLocation) ?? "No user Location")")
                
            }
        }
    }
}



