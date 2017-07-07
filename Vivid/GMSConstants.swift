//
//  GMSConstants.swift
//  Vivid
//
//  Created by Celia Gómez de Villavedón on 07/07/2017.
//  Copyright © 2017 Celia Gómez de Villavedón Pedrosa. All rights reserved.
//

import Foundation


var urlRequest = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=52.479209, 13.437409&radius=2500&type=bar&key=AIzaSyDa9Fh9sFFxVaeawHxr-nvRgZUeX1SWB74"


extension GMSClient {
    
    class func valueForAPIKey(named keyname:String) -> String {
        let filePath = Bundle.main.path(forResource: "ApiKeys", ofType: "plist")
        let plist = NSDictionary(contentsOfFile:filePath!)
        let value = plist?.object(forKey: keyname) as! String
        return value
    }
    
    
    // MARK: Constants
    struct Constants {
    
        // MARK: API Key

        static let ApiKey = GMSClient.valueForAPIKey(named:"GMSWebApiKey") //TYPE YOUR API KEY HERE INSTEAD
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "maps.googleapis.com"
        static let ApiPath = "/maps/api/"
    }
    
    // MARK: Methods
    struct Methods {
        
        // MARK: Search
        static let SearchPlace = "place/nearbysearch/json"
       
    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        static let ApiKey = "key"
        static let Types = "type"
        static let Location = "location"
        static let Radius = "radius"
    }
    
    struct ParameterValues {
        static let Bar = "bar"
        static let Radius = "2500"
        static let Neukölln = "52.479209, 13.437409"
        static let Kreuzberg = "52.499248, 13.403765"
        static let Mitte = "52.521785, 13.401039"
        static let currentLocation = ""
     
    }
}
