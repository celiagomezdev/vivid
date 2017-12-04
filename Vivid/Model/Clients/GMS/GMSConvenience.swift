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
import Sync

extension GMSClient {
    
    //Define location parameters for every neighbourhood.
    struct Neighbourhoods {
        static let Neukölln = "52.479209,13.437409"
        static let Kreuzberg = "52.499248,13.403765"
        static let Mitte = "52.521785,13.401039"
    }
    
    func getDataFromGMSApi(completion: @escaping (_ results: [[String:Any]]?, _ errorString: String?) -> Void) {
        
        var resultsArray = [[String:Any]]()
        var resultData = [String:Any]()
 
        let IDdictionary = Model.sharedInstance().getPlaceIDDictionary()

        for (name, placeId) in IDdictionary {

            self.getPlaceDetails(placeId) { (results, error) in
  
                guard (error == nil) else {
                    completion(nil, "getPlaceDetails Error: \(error!.localizedDescription)")
                    return
                }
                
                guard let result = results?["result"] as? [String:Any] else {
                    completion(nil, "Could not find result in results")
                    return
                }
                
                //Get place details and print in console
                resultData["name"] = name
                
                let location = self.getLocation(result)
                resultData["location"] = location
                
                let rating = self.getRating(result)
                resultData["rating"] = rating
                
                let website = self.getWebsite(result)
                resultData["website"] = website
                
                let placeTypes = self.getPlaceTypes(result)
                resultData["placeTypes"] = placeTypes
                
                let largePhotos = self.getLargePhotos(result)
                resultData["largePhotos"] = largePhotos
                
                let thumbPhotos = self.getThumbPhotos(result)
                resultData["thumbPhotos"] = thumbPhotos
                
                let openingHours = self.getOpeningHours(result)
                resultData["openingHours"] = openingHours
                
                resultsArray.append(resultData)
                completion(resultsArray, nil)
            }
        }
    }
    

    //MARK: Helper methods to get place details
    
    //Name:
    func getName(_ result: [String:Any]) -> String {
        
        guard let name = result["name"] as? String else {
            print("Could not find name in results")
            return ""
        }
        
        return name
    }
    
    //Location:
    
    func getLocation(_ result: [String:Any]) -> String {
        
        guard let geometry = result["geometry"] as? [String:Any] else {
            print("Could not find geometry in results")
            return ""
        }
        
        guard let location = geometry["location"] as? [String:Any] else {
            print("Could not find location in geometry results")
            return ""
        }
        
        guard let latitude = location["lat"] as? Double, let longitude = location["lng"] as? Double else {
            print("Could not find latitude or longitude in location results")
            return ""
        }
        
        let locationString = "\(latitude), \(longitude)"
        
        return locationString
    }
    

    //Rating:
    
    func getRating(_ result: [String:Any]) -> Int {
        
        guard let rating = result["rating"] as? Int else {
            print("Could not find rating in results")
            return 0
        }
        return rating
    }
    
    func getWebsite(_ result: [String:Any]) -> String {
        
        guard let website = result["website"] as? String else {
            print("Could not find website in results")
            return ""
        }
        
        return website
    }
    

    //Place Types:
    
    func getPlaceTypes(_ result: [String:Any]) -> [String] {
        
        guard let placeTypes = result["types"] as? [String] else {
            print("Could not find place types in results")
            return []
        }
        
        return placeTypes
    }
    
    func getOpeningHours(_ result: [String:Any]) -> [String:Any] {
        guard let openingHours = result["opening_hours"] as? [String:Any] else {
            print("Could not find opening hourse in results")
            return [:]
        }
        
        return openingHours
    }
    
    //Get Thumb Photos:
    func getThumbPhotos(_ result: [String:Any]) -> [String] {
        
        guard let photos = result["photos"] as? [[String:Any]] else {
            
            print("Could not find photos in results")
            return []
        }
        
        let photoURLArray = self.getPhotoUrlArray("300", photos)
        
        return photoURLArray
    }
    
    //Get Large Photos:
    func getLargePhotos(_ result: [String:Any]) -> [String] {
        
        guard let photos = result["photos"] as? [[String:Any]] else {
            
            print("Could not find photos in results")
            return []
        }
        
        let photoURLArray = self.getPhotoUrlArray("1500", photos)
        
        return photoURLArray
    }

    func getPhotoUrlArray(_ size: String, _ photos: [[String:Any]]) -> [String] {
        
        var photoUrlArray = [String]()
        
        for photo in photos {
            
            if let photoReference = photo["photo_reference"] as? String {
                let photoURL = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=\(size)&photoreference=\(photoReference)&key=\(GMSClient.Constants.ApiKey)"
                photoUrlArray.append(photoURL)
            }
        }
        
        return photoUrlArray
    }
    
    //Get and store place ID from GMS methods
    
    func getPlaceID (_ barName: String?,_ barAddress: String?, _ completionHanlderForPlaceID: @escaping (_ success: Bool, _ placeID: String?, _ errorString: String?) -> Void) {
        
        let parameters = [GMSClient.ParameterKeys.Radius: "10000", GMSClient.ParameterKeys.Types: "bar", GMSClient.ParameterKeys.Location: GMSClient.Neighbourhoods.Neukölln, "name": "\(barName!)"]
        
        let _ = GMSClient.sharedInstance().taskForGetMethod(GMSClient.Methods.SearchPlace, parameters: parameters as [String:Any]) { (results, error) in
            
            guard (error == nil) else {
                print("There was an error with your request: \(error!.localizedDescription)")
                completionHanlderForPlaceID(false, nil, "Get Request Failed")
                return
            }
            
            guard let parsedResults = results?["results"] as? [[String:Any]] else {
                print("Could not find results in results")
                return
            }
            
            for item in parsedResults {
                
                guard let itemName = item["name"] as? String, let itemAddress = item["vicinity"] as? String else {
                    completionHanlderForPlaceID(false, nil, "Could not find name or address in results")
                    return
                }
                
                guard (itemName == barName) || (itemAddress == barAddress) else {
                    completionHanlderForPlaceID(false, nil, "NOT SAVED. GMSName: \(itemName), GMSAddress: \(itemAddress) // databaseName: \(barName!), databaseAddress: \(barAddress!) ")
                    return
                }
                
                guard let placeID = item["place_id"] as? String else {
                    completionHanlderForPlaceID(false, nil, "Could not store Place ID in CompletionHandler for barName: \(barName!) \(String(describing: error?.localizedDescription))")
                    return
                }
                
                completionHanlderForPlaceID(true, placeID, nil)
            }
        }
    }
        
    func getPlaceDetails(_ placeID: String?, _ completionHanlderForPlaceDetails: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        let parameters = ["placeid": "\(placeID!)"]
        
        let _ = GMSClient.sharedInstance().taskForGetMethod(GMSClient.Methods.PlaceDetails, parameters: parameters as [String:Any]) { (results, error) in
            
            if let error = error {
                completionHanlderForPlaceDetails(nil, error)
            } else {
                completionHanlderForPlaceDetails(results, nil)
            }
        }
    }
}
