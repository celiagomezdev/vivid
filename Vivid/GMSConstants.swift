//
//  GMSConstants.swift
//  Vivid
//
//  Created by Celia Gómez de Villavedón on 07/07/2017.
//  Copyright © 2017 Celia Gómez de Villavedón Pedrosa. All rights reserved.
//

import Foundation


extension GMSClient {

    //Method to extract API Key from private file
    class func valueForAPIKey(named keyname:String) -> String {
        let filePath = Bundle.main.path(forResource: "Keys", ofType: "plist")
        let plist = NSDictionary(contentsOfFile:filePath!)
        let value = plist?.object(forKey: keyname) as! String
        return value
    }

    // MARK: Constants
    struct Constants {
    
        // MARK: API Key

        static let ApiKey = GMSClient.valueForAPIKey(named:"GMSWebApiKey") //YOUR API KEY HERE
        
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

}
