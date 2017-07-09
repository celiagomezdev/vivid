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
    
    //GET Search Request when user select Neighbourhood
    func getPlacesForSelectedNeighbourhood(_ searchText: String) {
        
        let parameters = getParametersForNeighbourhood(searchText)
        print("Parameters for Selected Neighbourhood: \(parameters)")
        
    }
    
    //GET Search Request when user select Current Location
    func getPlacesForUserLocation(_ userLocation: String) {
        let parameters = [GMSClient.ParameterKeys.Location: userLocation]
        print("User location: \(userLocation)")
        print("Parameters for User location: \(parameters)")
        
        
 
    }
    
    //Helper methods
    
    func getParametersForNeighbourhood(_ searchText: String) -> [String:Any] {
        
        var parameters = [String:Any]()
        
        if searchText == "Neukölln" {
            parameters = [GMSClient.ParameterKeys.Location: Neighbourhoods.Neukölln]
            print("Selected Neighbourhood: \(searchText)")
        }
        
        if searchText == "Kreuzberg" {
            parameters = [GMSClient.ParameterKeys.Location: Neighbourhoods.Kreuzberg]
            print("Selected Neighbourhood: \(searchText)")
        }
        
        if searchText == "Mitte" {
            parameters = [GMSClient.ParameterKeys.Location: Neighbourhoods.Mitte]
            print("Selected Neighbourhood: \(searchText)")
        }
        
        return parameters
    }
    

    // MARK: Shared Instance
    
    class func sharedInstance() -> GMSClient {
        struct Singleton {
            static var sharedInstance = GMSClient()
        }
        return Singleton.sharedInstance
    }
}

extension GMSClient {
    
    struct Neighbourhoods {
        
        static let Neukölln = "52.479209, 13.437409"
        static let Kreuzberg = "52.499248, 13.403765"
        static let Mitte = "52.521785, 13.401039"
        
    }
    
}
