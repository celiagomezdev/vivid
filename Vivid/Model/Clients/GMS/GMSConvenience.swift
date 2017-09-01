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
    
    //MARK: Update Core Data Model from GMS Api
    func updateNonSmokingBarsModelFromGMSApi() {
        
        var itemsPlaceIDSaved = 0
        var itemsRatingSaved = 0
        var itemsLocationSaved = 0
        var itemsPhotosSaved = 0
        var itemsPlaceTypesSaved = 0
        
        //Accesing Model
        
        managedObjectContext = dataStack.viewContext
        
        request.returnsObjectsAsFaults = false
        
        do {
            
            let results = try managedObjectContext.fetch(request)
            
            if results.count > 0 {
                
                for modelResult in results as! [NSManagedObject] {
                    if let name = modelResult.value(forKey: "name") as? String, let placeID = modelResult.value(forKey: "placeId") as? String {
                        
                        self.getPlaceDetails(placeID) { (results, error) in
                            
                            if let error = error {
                                
                                print("We could not get place details. \(error.localizedDescription)")
                                
                            } else {
                                
                                
                                if let result = results?["result"] as? [String:Any] {
                                    
                                    itemsPlaceIDSaved += 1
                                    
                                    //Get location as String and store
                                    if let geometry = result["geometry"] as? [String:Any] {
                                        
                                        if let location = geometry["location"] as? [String:Any] {
                                            
                                            if let latitude = location["lat"] as? Double, let longitude = location["lng"] as? Double {
                                                
                                                let location = "\(latitude), \(longitude)"
                                                
                                                itemsLocationSaved += 1
                                                modelResult.setValue(location, forKey: "location")
                                                
                                                do {
                                                    try self.managedObjectContext.save()
                                                    
                                                } catch {
                                                    
                                                    print("We couldn't save correctly the data into context")
                                                }
                                                
                                            } else {
                                                print("Could not find latitude, or longitud in results")
                                            }
                                        } else {
                                            print("Could not find location in results")
                                        }
                                    } else {
                                        print("Could not find geometry in results")
                                    }
                                    
                                    //Get rating as String and store
                                    if let rating = result["rating"] as? Int {
                                        print("Rating Saved")
                                        
                                        itemsRatingSaved += 1
                                        
                                        modelResult.setValue(rating, forKey: "rating")
                                        
                                    } else {
                                        print("Could not find rating in results")
                                    }
                                    
                                    do {
                                        try self.managedObjectContext.save()
                                        
                                    } catch {
                                        
                                        print("We couldn't save correctly the data into context")
                                    }
                                    
                                    if let placeTypes = result["types"] as? [String] {
                                        
                                        let data = NSKeyedArchiver.archivedData(withRootObject: placeTypes)
                                        
                                        itemsPlaceTypesSaved += 1
                                        
                                        modelResult.setValue(data, forKey: "placeTypes")
                                        
                                        
                                    } else {
                                        print("Could not find places types in results")
                                    }
                                    
                                    
                                    //Get photos as [String] and store
                                    if let photos = result["photos"] as? [[String:Any]] {
                                        
                                        let photoURLArray = self.getPhotoURLArray(photos)
                                        
                                        let data = NSKeyedArchiver.archivedData(withRootObject: photoURLArray)
                                        
                                        itemsPhotosSaved += 1
                                        
                                        modelResult.setValue(data, forKey: "photos")
                                        
                                        do {
                                            try self.managedObjectContext.save()
                                            
                                        } catch {
                                            
                                            print("We couldn't save correctly the data into context")
                                        }
                                    }
                                    
                                } else {
                                    
                                    if let status = results?["status"] as? String {
                                        print("Had error for place: \(name), with place id: \(placeID). \(status)")
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                print("No results in dataStack")
            }
        } catch {
            print("We couldn't save correctly the data into context")
        }
        
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when) {
            print("Nº Items TOTAL: \(self.nonSmokingBars.count)")
            print("Nº Items saved with Place_ID: \(itemsPlaceIDSaved)")
            print("Nº Items saved with Location: \(itemsLocationSaved)")
            print("Nº Items saved with Rating: \(itemsRatingSaved)")
            print("Nº Items saved with Photos: \(itemsPhotosSaved)")
            print("Nº Items saved with Places Types: \(itemsPhotosSaved)")
        }
    }
    
    func GetAndPrintDataFromGMSApi() {
        
        var itemsPlaceIDReceived = 0
        var itemsRatingReceived = 0
        var itemsLocationReceived = 0
        var itemsPhotosReceived = 0
        var itemsPlaceTypesReceived = 0
        
        //Accesing Model
        
        managedObjectContext = dataStack.viewContext
        
        request.returnsObjectsAsFaults = false
        
        do {
            
            let results = try managedObjectContext.fetch(request)
            
            if results.count > 0 {
                
                for modelResult in results as! [NSManagedObject] {
                    if let name = modelResult.value(forKey: "name") as? String, let placeID = modelResult.value(forKey: "placeId") as? String {
                        
                        self.getPlaceDetails(placeID) { (results, error) in
                            
                            if let error = error {
                                
                                print("We could not get place details. \(error.localizedDescription)")
                                
                            } else {
                                
                                
                                if let result = results?["result"] as? [String:Any] {
                                    
                                    itemsPlaceIDReceived += 1
                                    
                                    //Get location as String and store
                                    if let geometry = result["geometry"] as? [String:Any] {
                                        
                                        if let location = geometry["location"] as? [String:Any] {
                                            
                                            if let latitude = location["lat"] as? Double, let longitude = location["lng"] as? Double {
                                                
                                                let location = "\(latitude), \(longitude)"
                                                
                                                itemsLocationReceived += 1
                                                print(name)
                                                print(placeID)
                                                print(location)
                                                
                                            } else {
                                                print("Could not find latitude, or longitud in results")
                                            }
                                        } else {
                                            print("Could not find location in results")
                                        }
                                    } else {
                                        print("Could not find geometry in results")
                                    }
                                    
                                    //Get rating as String and store
                                    if let rating = result["rating"] as? Int {
                                        
                                        itemsRatingReceived += 1
                                        print(rating)
                                        
                                    } else {
                                        print("Could not find rating in results")
                                    }
                                    
                                    if let placeTypes = result["types"] as? [String] {
                                        
                                        itemsPlaceTypesReceived += 1
                                        
                                        print(placeTypes)
                                        
                                    } else {
                                        print("Could not find places types in results")
                                    }
                                    
                                    //Get photos as [String] and store
                                    if let photos = result["photos"] as? [[String:Any]] {
                                        
                                        let photoURLArray = self.getPhotoURLArray(photos)
                                        
                                        itemsPhotosReceived += 1
                                        
                                        print(photoURLArray)
                                        
                                    }
                                    
                                } else {
                                    
                                    if let status = results?["status"] as? String {
                                        print("Had error for place: \(name), with place id: \(placeID). \(status)")
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                print("No results in dataStack")
            }
        } catch {
            print("We couldn't save correctly the data into context")
        }
        
        let when = DispatchTime.now() + 4
        DispatchQueue.main.asyncAfter(deadline: when) {
            print("Nº Items TOTAL: \(self.nonSmokingBars.count)")
            print("Nº Items saved with Place_ID: \(itemsPlaceIDReceived)")
            print("Nº Items saved with Location: \(itemsLocationReceived)")
            print("Nº Items saved with Rating: \(itemsRatingReceived)")
            print("Nº Items saved with Photos: \(itemsPhotosReceived)")
            print("Nº Items saved with Places Types: \(itemsPhotosReceived)")
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
    
    
    func getPlaceID (_ barName: String?,_ barAddress: String?, _ completionHanlderForPlaceID: @escaping (_ success: Bool, _ placeID: String?, _ errorString: String?) -> Void) {
        
        let parameters = [GMSClient.ParameterKeys.Radius: "10000", GMSClient.ParameterKeys.Types: "bar", GMSClient.ParameterKeys.Location: GMSClient.Neighbourhoods.Neukölln, "name": "\(barName!)"]
        
        let _ = GMSClient.sharedInstance().taskForGetMethod(GMSClient.Methods.SearchPlace, parameters: parameters as [String:Any]) { (results, error) in
            
            if let error = error {
                
                print("ERROR: \(error.localizedDescription)")
                completionHanlderForPlaceID(false, nil, error.localizedDescription)
                
            } else {
                
                if let parsedResults = results?["results"] as? [[String:Any]] {
                    
                    for item in parsedResults {
                        
                        if let itemName = item["name"] as? String, let itemAddress = item["vicinity"] as? String {
                            
                            if (itemName == barName) || (itemAddress == barAddress) {
                                
                                if let placeID = item["place_id"] as? String {
                                    completionHanlderForPlaceID(true, placeID, nil)
                                    
                                } else {
                                    completionHanlderForPlaceID(false, nil, "Could not store Place ID in CompletionHandler for barName: \(barName!) \(String(describing: error?.localizedDescription))")
                                }
                            } else {
                                completionHanlderForPlaceID(false, nil, "NOT SAVED. GMSName: \(itemName), GMSAddress: \(itemAddress) // databaseName: \(barName!), databaseAddress: \(barAddress!) ")
                            }
                        } else {
                            completionHanlderForPlaceID(false, nil, "Could not find itemName or itemAddress in parsed results : \(String(describing: error?.localizedDescription))")
                        }
                    }
                }
            }
        }
    }
    
    func savePlaceIDs() {
        
        managedObjectContext = dataStack.viewContext
        
        request.returnsObjectsAsFaults = false
        
        var placeIDSaved = 0
        
        do {
            
            let results = try managedObjectContext.fetch(request)
            
            if results.count > 0 {
                
                for result in results as! [NSManagedObject] {
                    
                    if let barName = result.value(forKey: "name") as? String, let barAddress = result.value(forKey: "address") as? String {
                        
                        self.getPlaceID(barName, barAddress) { (success, placeID, error) in
                            
                            if success {
                                
                                if let placeID = placeID {
                                    
                                    print("Place ID: \(placeID) for bar: \(barName)")
                                    result.setValue(placeID, forKey: "placeId")
                                    
                                }
                                
                                do {
                                    placeIDSaved += 1
                                    try self.managedObjectContext.save()
                                } catch {
                                    print("We could not save correctly the PLACE ID into context")
                                }
                                
                            }
                        }
                    }
                }
            } else {
                print("No results")
            }
        } catch {
            print("We couldn't save correctly the data into context")
        }
        
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when) {
            
            print("Nº Items Place_ID Saved: \(placeIDSaved)")
            
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
