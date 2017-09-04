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
    
    
    func getAndPrintDataFromGMSApi() {
        
        let results = fetchManagedObject()
        
        if results.count > 0 {
            
            for modelResult in results as! [NSManagedObject] {
                
                if let placeID = modelResult.value(forKey: "placeId") as? String, let barName = modelResult.value(forKey: "name") as? String {
                    
                    self.getPlaceDetails(placeID) { (results, error) in
                        
                        guard (error == nil) else {
                            print("Could not get place details")
                            return
                        }
                        
                        guard let result = results?["result"] as? [String:Any] else {
                            print("Could not get result from results")
                            return
                        }
                        
                        //Get place details
                        let location = self.getLocation(result)
                        let rating = self.getRating(result)
                        let placeTypes = self.getPlaceTypes(result)
                        let photos = self.getPhotos(result)
                        
                        //Print in console:
                        print("Bar name: \(barName)")
                        print("Location: \(location)")
                        print("rating: \(rating)")
                        print("placeTypes: \(placeTypes)")
                        print("Photos: \(photos)")
                    }
                }
            }
        }
    }
    
    
    //MARK: Update Core Data Model from GMS Api
    func updateNonSmokingBarsModelFromGMSApi() {
        
        let results = fetchManagedObject()
        
        if results.count > 0 {
            
            for modelResult in results as! [NSManagedObject] {
                
                if let placeID = modelResult.value(forKey: "placeId") as? String {
                    
                    self.getPlaceDetails(placeID) { (results, error) in
                        
                        guard (error == nil) else {
                            print("Could not get place details")
                            return
                        }
                        
                        guard let result = results?["result"] as? [String:Any] else {
                            print("Could not get result from results")
                            return
                        }
                        
                        //Get place details
                        let location = self.getLocation(result)
                        let rating = self.getRating(result)
                        let placeTypes = self.getPlaceTypes(result)
                        let photos = self.getPhotos(result)
                        
                        //Store into context
                        self.storeLocation(modelResult, location)
                        self.storeRating(modelResult, rating)
                        self.storePlaceTypes(modelResult, placeTypes)
                        self.storePhotos(modelResult, photos)
                    }
                }
            }
        }
    }
    
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
    
    //Method to store Location in Model
    func storeLocation(_ modelResult: NSManagedObject,_ location: String) {
        
        //Store location in Model
        modelResult.setValue(location, forKey: "location")
        
        do {
            try self.managedObjectContext.save()
        } catch {
            print("Could not save correctly location into context")
        }
    }
    
    //Method to store Rating in Model
    func getRating(_ result: [String:Any]) -> Int {
        
        guard let rating = result["rating"] as? Int else {
            print("Could not find rating in results")
            return 0
        }
        return rating
    }
    
    func storeRating(_ modelResult: NSManagedObject,_ rating: Int) {
        
        //Set value and save in Model
        modelResult.setValue(rating, forKey: "rating")
        
        do {
            try self.managedObjectContext.save()
        } catch {
            print("Could not save correctly rating into context")
        }
    }
    
    //Method to store Place Types in Model
    func getPlaceTypes(_ result: [String:Any]) -> [String] {
        
        guard let placeTypes = result["place_types"] as? [String] else {
            print("Could not find place types in results")
            return []
        }
        
        return placeTypes
    }
    
    func storePlaceTypes(_ modelResult: NSManagedObject,_ placeTypes: [String]) {
        //Set value and save in Model
        let data = NSKeyedArchiver.archivedData(withRootObject: placeTypes)
        
        modelResult.setValue(data, forKey: "placeTypes")
        
        do {
            try self.managedObjectContext.save()
        } catch {
            print("Could not save correctly place types into context")
        }
    }
    
    //Method to store Photos in Model
    func getPhotos(_ result: [String:Any]) -> [String] {
        
        guard let photos = result["photos"] as? [[String:Any]] else {
            print("Could not find place types in results")
            return []
        }
        
        let photoURLArray = self.getPhotoURLArray(photos)
        
        return photoURLArray
    }
    
    func storePhotos(_ modelResult: NSManagedObject,_ photos: [String]) {
        
        //Set value and save in Model
        let data = NSKeyedArchiver.archivedData(withRootObject: photos)
        
        modelResult.setValue(data, forKey: "photos")
        
        do {
            try self.managedObjectContext.save()
        } catch {
            print("Could not save correctly place types into context")
        }
    }
    
    func fetchManagedObject() -> [Any] {
        
        managedObjectContext = dataStack.viewContext
        
        request.returnsObjectsAsFaults = false
        
        do {
            
            let results = try managedObjectContext.fetch(request)
            return results
            
        } catch {
            print("Could not fetch the data")
            return []
        }
    }
    
    
    // Get Array of URL photos
    func getPhotoURLArray(_ photos: [[String:Any]]) -> [String] {
        
        var photoURLArray = [String]()
        
        for photo in photos {
            
            if let photoReference = photo["photo_reference"] as? String {
                
                let photoURL = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=2048&photoreference=\(photoReference)&key=\(GMSClient.Constants.ApiKey)"
                
                photoURLArray.append(photoURL)
            }
        }
        return photoURLArray
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
            
            if let parsedResults = results?["results"] as? [[String:Any]] {
                
                for item in parsedResults {
                    
                    guard let itemName = item["name"] as? String, let itemAddress = item["vicinity"] as? String else {
                        completionHanlderForPlaceID(false, nil, "Could not find name or address in results")
                        return
                    }
                    
                    if (itemName == barName) || (itemAddress == barAddress) {
                        
                        if let placeID = item["place_id"] as? String {
                            completionHanlderForPlaceID(true, placeID, nil)
                            
                        } else {
                            completionHanlderForPlaceID(false, nil, "Could not store Place ID in CompletionHandler for barName: \(barName!) \(String(describing: error?.localizedDescription))")
                        }
                    } else {
                        completionHanlderForPlaceID(false, nil, "NOT SAVED. GMSName: \(itemName), GMSAddress: \(itemAddress) // databaseName: \(barName!), databaseAddress: \(barAddress!) ")
                    }
                }
            }
        }
    }
    
    func savePlaceIDs() {
        
        var placeIDSaved = 0
        
        let results = fetchManagedObject()
        
        guard results.count > 0 else {
            print("Results is empty")
            return
        }
        
        for result in results as! [NSManagedObject] {
            
            if let barName = result.value(forKey: "name") as? String, let barAddress = result.value(forKey: "address") as? String {
                
                self.getPlaceID(barName, barAddress) { (success, placeID, error) in
                    
                    guard success, let placeID = placeID else {
                        print("Getting place ID was not succesful")
                        return
                    }
                    
                    result.setValue(placeID, forKey: "placeId")
                    
                    
                    //Store place ID and handle error
                    do {
                        try self.managedObjectContext.save()
                        placeIDSaved += 1
                    } catch {
                        print("Could not save place id into context")
                    }
                }
            }
        }
        
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when) {
            print("PlaceIDs saved count: \(placeIDSaved)")
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
