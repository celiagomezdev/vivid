//
//  Model.swift
//  Vivid
//
//  Created by Celia Gómez de Villavedón on 07/08/2017.
//  Copyright © 2017 Celia Gómez de Villavedón Pedrosa. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Sync


class Model: NSObject {
    
    let dataStack = DataStack(modelName: "NonSmokingBarModel")
    var nonSmokingBars = [NonSmokingBar]()
    var managedObjectContext: NSManagedObjectContext!
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "NonSmokingBar")
    var newManagedObjectContext: NSManagedObjectContext!
    
    override init() {
        super.init()
    }
    
    //MARK: Sync data into Model from a JSON file (Google Sheets Database )
    func importFromJSON() {
        
        self.getDataWith { (json, error) in
            
            guard error == nil else { print("Could not import the JSON to NonSmoking barModel"); return }
            
            if let jsonResult = json?["results"] as? [[String:Any]] {
                
                self.dataStack.sync(jsonResult, inEntityNamed: "NonSmokingBar") { error in
                    guard error == nil else { print("Could not import the JSON to NonSmoking barModel"); return }
                    print("SAVED \(jsonResult.count) in core data")
                }
                
            } else {
                print("Could not get data as [[String:Any]]")
            }
        }
        
        print("importListData called")
        
    }
    
    //MARK: Export JSON from model - ERROR: I cannot get a json object
    func exportToJSON () {
        
        managedObjectContext = dataStack.viewContext
        
        request.returnsObjectsAsFaults = false
        
        do {
            
            let results = try managedObjectContext.fetch(request)
            
            if results.count > 0 {
                
                for entry in results as! [NSManagedObject] {
                    
                    let entriesValues = entry.export()
                    print(entriesValues)
                        
                    }
            }
        } catch {
            print("We could not fetch the data")
        }

    }
    
    //Parse data from JSON file
    func getDataWith(completion: @escaping (_ result: AnyObject?,_ error: NSError?) -> Void) {
        
        guard let url = URL(string: GMSClient.Constants.myListURL) else { return }
        print(url)
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard error == nil else {
                completion(nil, error! as NSError)
                print("Could not receive the data from NonSmokingBars Sheet: \(String(describing: error))")
                return
            }
            
            guard let data = data else {
                print("No data")
                return
            }
            var parsedResult: AnyObject! = nil
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
                
                DispatchQueue.main.async {
                    print("JSON data sent to completion handler)")
                    completion(parsedResult, nil)
                }
            } catch {
                let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
                completion(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
                
            }
            }.resume()
    }
    

    //MARK: Update Core Data Model from GMS Api
    func updateNonSmokingBarsModelFromGMSApi() {
        
        var itemsPlaceIDSaved = 0
        var itemsRatingSaved = 0
        var itemsLocationSaved = 0
        var itemsPhotosSaved = 0
        
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
                                    
                                    //Get photos as [String] and store
                                    if let photos = result["photos"] as? [[String:Any]] {
                                        
                                        let photoURLArray = self.getPhotoURLArray(photos)
                                        
                                        let data = NSKeyedArchiver.archivedData(withRootObject: photoURLArray)
                                        
                                        itemsPhotosSaved += 1
   
                                        modelResult.setValue(data, forKey: "photos")
                                    }
                                    
                                } else {
                                    
                                    if let status = results?["status"] as? String {
                                        print("Had error for place: \(name), with place id: \(placeID). \(status)")
                                    }
                                }
                            }
                        }
                    }
 
                    do {
                        try self.managedObjectContext.save()
                        
                    } catch {
                        
                        print("We couldn't save correctly the data into context")
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
            print("Nº Items Place_ID: \(itemsPlaceIDSaved)")
            print("Nº Items Location: \(itemsLocationSaved)")
            print("Nº Items Rating: \(itemsRatingSaved)")
            print("Nº Items Photos: \(itemsPhotosSaved)")
        }
    }
    
    
    func updateNonSmokingBarsModelFromGMSApiSecond() {
        
        var itemsRatingSaved = 0
        var itemsLocationSaved = 0
        
        //Accesing Model
        
        managedObjectContext = dataStack.viewContext
        
        request.returnsObjectsAsFaults = false
        
        do {
            
            let results = try managedObjectContext.fetch(request)
            
            if results.count > 0 {
                
                for modelResult in results as! [NSManagedObject] {
                    if let barName = modelResult.value(forKey: "name") as? String, let placeID = modelResult.value(forKey: "placeId") as? String {
                        
                        self.getPlaceDetails(placeID) { (results, error) in
                            
                            if let error = error {
                                
                                print("We could not get place details. \(error.localizedDescription)")
                                
                            } else {
                                
                                
                                if let result = results?["result"] as? [String:Any] {
                                    
                                    //Get location as String
                                    if let geometry = result["geometry"] as? [String:Any] {
                                        
                                        if let location = geometry["location"] as? [String:Any] {
                                            
                                            if let latitude = location["lat"] as? Double, let longitude = location["lng"] as? Double {
                                                
                                                let location = "\(latitude), \(longitude)"
                                                
                                                itemsLocationSaved += 1
                                                print("bar: \(barName). Location: \(location)")
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
                                    
                                    //Get rating as String
                                    if let rating = result["rating"] as? Int {
                                        print("bar: \(barName). Rating: \(rating)")
                                        
                                        itemsRatingSaved += 1
                                        
                                        modelResult.setValue(rating, forKey: "rating")
                                        
                                        do {
                                            try self.managedObjectContext.save()
                                            
                                        } catch {
                                            
                                            print("We couldn't save correctly the data into context")
                                        }
                                    
                                        
                                    } else {
                                        print("Could not find rating in results")
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
            print("Nº Items Location: \(itemsLocationSaved)")
            print("Nº Items Rating: \(itemsRatingSaved)")
        }
    }

    
    func updateNonSmokingBarsModelFromGMSApiThird() {
        
        var itemsPhotosReceived = 0
        var itemsPlacesTypesReceived = 0
        
        
        //Accesing Model
        
        managedObjectContext = dataStack.viewContext
        
        request.returnsObjectsAsFaults = false
        
        do {
            
            let results = try managedObjectContext.fetch(request)
            
            if results.count > 0 {
                
                for modelResult in results as! [NSManagedObject] {
                    if let barName = modelResult.value(forKey: "name") as? String, let placeID = modelResult.value(forKey: "placeId") as? String {
                        
                        self.getPlaceDetails(placeID) { (results, error) in
                            
                            if let error = error {
                                
                                print("We could not get place details. \(error.localizedDescription)")
                                
                            } else {
                                
                                if let result = results?["result"] as? [String:Any] {
                                    
                                    //Get photos as [String] and store
                                    if let photos = result["photos"] as? [[String:Any]] {
                                        
                                        let photoURLArray = self.getPhotoURLArray(photos)
                                        itemsPhotosReceived += 1
                                        print("Bar: \(barName)")
                                        print(photoURLArray)
                                        
                                    } else {
                                        
                                        print("Could not find photos in results: \(barName)")
                                    }
                                    
                                    if let placeTypes = result["types"] as? [String] {
                                        
                                        itemsPlacesTypesReceived += 1
                                        print(placeTypes)
                                        
                                    } else {
                                        print("Could not find places types in results")
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
            print("Nº Items Photos: \(itemsPhotosReceived)")
            print("Nº Items Places Types: \(itemsPlacesTypesReceived)")
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
    
    
    //MARK: Helper methods for saving data into Model
    
    // Add entry manually
    
    func addEntryManually() {
        
        managedObjectContext = dataStack.viewContext
        
        let newEntry = NSEntityDescription.insertNewObject(forEntityName: "NonSmokingBar", into: managedObjectContext)
        
        let photos = ["a", "b", "c"]
        
        let data = NSKeyedArchiver.archivedData(withRootObject: photos)
        
      
        newEntry.setValue("Laika", forKey: "name")
        newEntry.setValue(data, forKey: "photos")
        
        do {
            try managedObjectContext.save()
            print("SAVED")
        } catch {
            print("We could not save into context")
        }

    }
    
    // Load data - ERROR: Cannot extract photos as [String]
    
    func loadDataNew() {
        
        managedObjectContext = dataStack.viewContext
        
        request.returnsObjectsAsFaults = false
        
        do {
            
            let results = try managedObjectContext.fetch(request)
            
            if results.count > 0 {
                
                for result in results as! [NSManagedObject] {
        
                    if let name = result.value(forKey: "name") as? String {
                        print(name)
                    }
                    if let photos = result.value(forKey: "photos") as? Data {
                        
                        let photos = NSKeyedUnarchiver.unarchiveObject(with: photos) as? [String]
   
                        print(photos ?? "No photos")
                    }
                    
                }
            }
        } catch {
            print("Error")
        }
    }
    
   
    //Update placeID's for some entries
    func addPlaceIDManually() {
        
        managedObjectContext = dataStack.viewContext
        
        request.returnsObjectsAsFaults = false
        
        do {
            
            let results = try managedObjectContext.fetch(request)
            print("nº in Database: \(results.count)")
            
            if results.count > 0 {
                
                for result in results as! [NSManagedObject] {
                    
                    if let barName = result.value(forKey: "name") as? String {
                        
                        switch barName {
                            
                        case "K-Fetisch":
                            print("SAVED place id for bar: \(barName)")
                            result.setValue("ChIJwbcY56VPqEcRWeH0D3fTHf0", forKey: "placeId")
                        case "Café Pförtner":
                            print("SAVED place id for bar: \(barName)")
                            result.setValue("ChIJI-j0Uy9SqEcRPfHhhUyfajo", forKey: "placeId")
                        case "Mano":
                            print("SAVED place id for bar: \(barName)")
                            result.setValue("ChIJQwk7-kpOqEcRZwckKwSnWq0", forKey: "placeId")
                        case "Ungeheuer":
                            print("SAVED place id for bar: \(barName)")
                            result.setValue("ChIJfT45VplPqEcRjouZhssZ7M8", forKey: "placeId")
                        case "Wolf Kino":
                            print("SAVED place id for bar: \(barName)")
                            result.setValue("ChIJFyPA2KVPqEcRTNkgWcCNCHg", forKey: "placeId")
                        case "Hops & Barley":
                            print("SAVED place id for bar: \(barName)")
                            result.setValue("ChIJbQ8FyVhOqEcRWwWTSlK_3W4", forKey: "placeId")
                        case "Laika":
                            print("SAVED place id for bar: \(barName)")
                            result.setValue("ChIJl86BkJ5PqEcRwLxtNiNWZMo", forKey: "placeId")
                        default:
                            print("We couldn't set the place id for bar: \(barName)")
                        }
                        
                        do {
                            try managedObjectContext.save()
                            print("PLACE ID UPDATED")
                        } catch {
                            print("We could not save correctly the PLACE ID into context")
                        }
                    }
                }
            }
        }  catch {
            print("We couldn't save correctly the data into context")
        }
    }
    
    //Load database entries in an array
    
    func loadPlaceIDResults() {
        
        managedObjectContext = dataStack.viewContext
        
        request.returnsObjectsAsFaults = false
        
        do {
            nonSmokingBars = try managedObjectContext.fetch(request) as! [NonSmokingBar]
            print("Nº in Array: \(nonSmokingBars.count)")
            
            var barsWithoutPlaceID = 0
            
            for result in nonSmokingBars {
                if let databaseName = result.name {
                    if result.placeId == nil {
                        barsWithoutPlaceID += 1
                        print("Name: \(databaseName), no place_id")
                    }
                } else {
                    print("No name in our Array from database")
                }
            }
            
            let when = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: when) {
                print("Nº total bars: \(self.nonSmokingBars.count)")
                print("Nº bars with place id: \(barsWithoutPlaceID)")
            }
            
        } catch {
            print("Could not load data from database: \(error.localizedDescription)")
        }
    }
    
    
    func loadResults() {
        
        managedObjectContext = dataStack.viewContext
        
        request.returnsObjectsAsFaults = false
        
        do {
            nonSmokingBars = try managedObjectContext.fetch(request) as! [NonSmokingBar]
            print("Nº in Array: \(nonSmokingBars.count)")
            
            for result in nonSmokingBars {
                if let databaseName = result.name {
                    print("Name: \(databaseName)")
                }
                if let databaseAddress = result.address {
                    print("Address: \(databaseAddress)")
                }
                if let databaseLocation = result.location {
                    print("Location: \(databaseLocation)")
                }
                if let databaseNeighbourhood = result.neighbourhood {
                    print("Neighbourhood: \(databaseNeighbourhood)")
                }
                
                print("Postal Code: \(result.postalCode)")
                
                print("Rating: \(result.rating)")
                
                if let databasePlaceID = result.placeId {
                    print("Place ID: \(databasePlaceID)")
                }
    
                if let databaseChecked = result.checked {
                    print("Checked: \(databaseChecked)")
                }
                
                if let databaseSmokingType = result.smokingType {
                    print("SmokingType: \(databaseSmokingType)")
                }
                
                /*ERROR HERE
                 if let databasePhotos = result.photos {
                 if let photos = NSKeyedUnarchiver.unarchiveObject(with: databasePhotos as Data) as? [String] {
                 print("Photos: \(photos)")
                 } else {
                 print("No photos")
                 }
                 }*/
            }
        } catch {
            print("Could not load data from database: \(error.localizedDescription)")
        }
    }

    func changeManually() {
        
        managedObjectContext = dataStack.viewContext
        
        request.returnsObjectsAsFaults = false
        
        do {
            
            let results = try managedObjectContext.fetch(request)
            
            if results.count > 0 {
                
                for result in results as! [NSManagedObject] {
                    
                    if let barName = result.value(forKey: "name") as? String {
                        
                        if barName == "Laika " {
                            
                            result.setValue("Laika", forKey: "name")
                            
                            do {
                                try managedObjectContext.save()
                                print("UPDATED")
                            } catch {
                                print("We could not save correctly the PLACE ID into context")
                            }
                        }
                    }
                }
            }
        } catch {
            print("We couldn't save correctly the data into context")
        }
    }

    // Delete entry
    func deleteManually() {
        
        managedObjectContext = dataStack.viewContext
        
        request.returnsObjectsAsFaults = false
        
        do {
            
            let results = try managedObjectContext.fetch(request)
            
            if results.count > 0 {
                
                for result in results as! [NSManagedObject] {
                    
                    if let barName = result.value(forKey: "name") as? String {
                        
                        if barName == "Kptn A. Müller" {
                            print("Object deleted: \(result)")
                            managedObjectContext.delete(result)
                        }
                        
                        do {
                            try managedObjectContext.save()
                        } catch {
                            print("We could not save correctly the PLACE ID into context")
                        }
                    }
                }
            }
        } catch {
            print("We couldn't save correctly the data into context")
        }
    }
    
    // MARK: Shared Instance

    class func sharedInstance() -> Model {
        struct Singleton {
            static var sharedInstance = Model()
        }
        return Singleton.sharedInstance
    }
}
