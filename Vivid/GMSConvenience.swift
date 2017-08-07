//
//  GMSConvenience.swift
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

extension GMSClient {
    
    //GET Search Request when user select Neighbourhood
    //TODO: Change _ results: AnyObject? for [GMSPlace]?
    func getPlacesForSelectedNeighbourhood(_ searchText: String, completionHandlerForPlaces: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        let parameters = [ParameterKeys.Radius: "2500", ParameterKeys.Types: "bar", GMSClient.ParameterKeys.Location: getLocationForNeighbourhood(searchText)]
        print(parameters)
        
        let task = taskForGetMethod(Methods.SearchPlace, parameters: parameters as [String: Any]) { (results, error) in
            
            //Send the desired values to completion handler
            if let error = error {
                print(error)
                completionHandlerForPlaces(nil, error)
            } else {
                completionHandlerForPlaces(results, nil)
                print("Sent results to completion handler for places")
            }
        }
    }
    
    //GET Search Request when user select Current Location
    func getPlacesForUserLocation(_ userLocation: String) {
        
        //TODO: Call TaskforGetMethod
        let parameters = [ParameterKeys.Radius: "2500", ParameterKeys.Types: "bar", GMSClient.ParameterKeys.Location: userLocation]
        print("User location: \(userLocation)")
        print("Parameters for User location: \(parameters)")
        
    }
    
    //Define parameters for every neighbourhood.
    func getLocationForNeighbourhood(_ searchText: String) -> String {
        
        var location = ""
        
        if searchText == "Neukölln" {
            location = Neighbourhoods.Neukölln
            print("Selected Neighbourhood: \(searchText)")
        }
        
        if searchText == "Kreuzberg" {
            location = Neighbourhoods.Kreuzberg
            print("Selected Neighbourhood: \(searchText)")
        }
        
        if searchText == "Mitte" {
            location = Neighbourhoods.Mitte
            print("Selected Neighbourhood: \(searchText)")
        }
        
        return location
    }
    
    struct Neighbourhoods {
        
        static let Neukölln = "52.479209,13.437409"
        static let Kreuzberg = "52.499248,13.403765"
        static let Mitte = "52.521785,13.401039"
        
    }
    
    
//    func updateNonSmokingBarsModelFromGMSApi() {
//        
//        let parameters = [ParameterKeys.Radius: "10000", ParameterKeys.Types: "bar", GMSClient.ParameterKeys.Location: "52.479209,13.437409", "name": Model.sharedInstance().dataStack.fetch(]
//        
//         Model.sharedInstance().getDataWith { (json, error) in
//            
//            guard error == nil else { print("Could not import the JSON to NonSmoking barModel"); return }
//            
//            if let jsonResult = json?["results"] as? [[String:Any]] {
//                
//                Model.sharedInstance().dataStack.sync(jsonResult, inEntityNamed: "NonSmokingBar") { error in
//                    guard error == nil else { print("Could not import the JSON to NonSmoking barModel"); return }
//                    print("SAVED \(jsonResult.count) in data base")
//                }
//                
//            } else {
//                print("Could not get data as [[String:Any]]")
//            }
//        }
//    }
//    
//    func importPhotoURLArrayFrom(_ placeId: String) {
//    print("photos")
//    }
//    
}
