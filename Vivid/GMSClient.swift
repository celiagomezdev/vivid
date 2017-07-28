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
    
    //MARK: Properties
    var session = URLSession.shared
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    
    //MARK: GET
    
    func taskForGetMethod(_ method: String, parameters: [String:Any], completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        //Set the parameters
        var parametersWithApiKey = parameters
        parametersWithApiKey[ParameterKeys.ApiKey] = Constants.ApiKey as Any
        
        //Build the URL and configure the request
        let request = NSMutableURLRequest(url: gmsURLFromParameters(parametersWithApiKey, withPathExtension: method))
        
        if let requestURL = request.url {
            print("The request url is: \(requestURL)")
        }

        //Make the request
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(nil, NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
            }
            
         //GUARD: Was there an error?
            guard (error == nil) else {
                sendError("There was an error with your request: \(String(describing: error))")
                return
            }
            
        //GUARD: Did we get a succesfull 2XX response?
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
        //GUARD: Was there any data returned?
            guard let data = data else {
                sendError("No data was retured by the request!")
                return
            }
           
        //Parse the data and use the data (happens in completion handler)
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
   
        }
        
        print("func taskForGetMethod. We could parse the data.")
        task.resume()
        return task
            
    }

    //GET Search Request when user select Neighbourhood
    //TODO: Change _ results: AnyObject? for [GMSPlace]?
    func getPlacesForSelectedNeighbourhood(_ searchText: String, completionHandlerForPlaces: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask? {
        
        let parameters = [ParameterKeys.Radius: "2500", ParameterKeys.Types: "bar", GMSClient.ParameterKeys.Location: getLocationForNeighbourhood(searchText)]
        print(parameters)
        
        let task = taskForGetMethod(Methods.SearchPlace, parameters: parameters as [String: Any]) { (results, error) in

            //Send the desired values to completion handler
            if let error = error {
                completionHandlerForPlaces(nil, error)
            } else {
                completionHandlerForPlaces(results, nil)
                print("Sent results to completion handler for places")
            }
        }
        
      return task
     }
    
    //GET Search Request when user select Current Location
    func getPlacesForUserLocation(_ userLocation: String) {
        
        //TODO: Call TaskforGetMethod
        let parameters = [ParameterKeys.Radius: "2500", ParameterKeys.Types: "bar", GMSClient.ParameterKeys.Location: userLocation]
        print("User location: \(userLocation)")
        print("Parameters for User location: \(parameters)")

    }
    
    //MARK: Helpers
    
    //Given raw JSON, return a usable Foundtion Object
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey: "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
     completionHandlerForConvertData(parsedResult, nil)
    }


    //Create a url from parameters
    
    private func gmsURLFromParameters(_ parameters: [String: Any], withPathExtension: String? = nil) -> URL {
        
     var components = URLComponents()
        components.scheme = GMSClient.Constants.ApiScheme
        components.host = GMSClient.Constants.ApiHost
        components.path = GMSClient.Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
    
        return components.url!
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
        
        static let Neukölln = "52.479209,13.437409"
        static let Kreuzberg = "52.499248,13.403765"
        static let Mitte = "52.521785,13.401039"
        
    }
    
}
