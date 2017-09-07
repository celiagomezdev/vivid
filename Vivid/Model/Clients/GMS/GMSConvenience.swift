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
    
    func getDataFromGMSApi(_ completionHanlderForGMSData: @escaping (_ modelResults: [Any]?, _ results: [String:Any]?,_ errorString: String?) -> Void) {
        
        var resultsArray = [String:Any]()
        var modelResultsArray = [Any]()
        
        managedObjectContext = dataStack.viewContext
        
        request.returnsObjectsAsFaults = false
        
        do {
            
            let modelResults = try managedObjectContext.fetch(request)
            
            guard !modelResults.isEmpty else {
                print("modelResults is empty")
                return
            }
            
            modelResultsArray.append(modelResults)
            
            for modelResult in modelResults as! [NSManagedObject] {
                
                guard let placeID = modelResult.value(forKey: "placeId") as? String, let _ = modelResult.value(forKey: "name") as? String else {
                    print("Could not find ")
                    return
                }
                
                self.getPlaceDetails(placeID) { (results, error) in
                    
                    guard (error == nil) else {
                        print("Could not get place details")
                        completionHanlderForGMSData(nil, nil, error?.localizedDescription)
                        return
                    }
                    
                    guard let result = results?["result"] as? [String:Any] else {
                        print("Could not get result from results")
                        completionHanlderForGMSData(nil, nil, error?.localizedDescription)
                        return
                    }
                    
                    //Get place details and print in console
                    let name = self.getName(result)
                    resultsArray["name"] = name
                    
                    let location = self.getLocation(result)
                    resultsArray["location"] = location
                    //                    print("Bar name: \(barName)")
                    //                    print("Location: \(location)")
                    
                    let rating = self.getRating(result)
                    resultsArray["rating"] = rating
                    //                    print("Rating: \(rating)")
                    
                    let placeTypes = self.getPlaceTypes(result)
                    resultsArray["placeTypes"] = placeTypes
                    //                    print("placeTypes: \(placeTypes)")
                    
                    let photos = self.getPhotos(result)
//                    resultsArray["photos"] = photos
                    //                    print("Photos: \(photos)")
                }
            }
        } catch {
            print("Could not fetch the data")
        }
        
        completionHanlderForGMSData(modelResultsArray, resultsArray, nil)
        print("GMS Results count: \(resultsArray.count)")
        print("Sent data to completion handler for GMSData")
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
    

    //Place Types:
    
    func getPlaceTypes(_ result: [String:Any]) -> [String] {
        
        guard let placeTypes = result["types"] as? [String] else {
            print("Could not find place types in results")
            return []
        }
        
        return placeTypes
    }
    
    //Photos:
    func getPhotos(_ result: [String:Any]) -> [Int:Any]? {
        
        guard let photos = result["photos"] as? [[String:Any]] else {
            
            print("Could not find photos in results")
            return [:]
        }
        
        let photoURLArray = self.getPhotoURLArrayOfDictionaries(photos)
        
        return photoURLArray
    }

    //TEMP: Get Array of URL photos
    func getPhotoURLArrayOfDictionaries(_ photos: [[String:Any]]) -> [Int:Any] {
        
        var photoURLDictionary = [Int:Any]()
        
        var fotoURLSizes = [String:Int]()
        
        fotoURLSizes = ["thumb": 100, "small" : 300]
        
        for photo in photos {
            
            if let photoReference = photo["photo_reference"] as? String {
                
                for (name, size) in fotoURLSizes {
                    
                    let photoURL = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=\(size)&photoreference=\(photoReference)&key=\(GMSClient.Constants.ApiKey)"
                    
                    photoURLDictionary[+1] = [name: photoURL]
                }
            }
        }
        print(photoURLDictionary)
        return photoURLDictionary
    }
    
    //Old method
    func getPhotoUrlArray(_ photos: [[String:Any]]) -> [String] {
        
        var photoUrlArray = [String]()
        
        for photo in photos {
            
            if let photoReference = photo["photo_reference"] as? String {
                let photoURL = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=300&photoreference=\(photoReference)&key=\(GMSClient.Constants.ApiKey)"
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
