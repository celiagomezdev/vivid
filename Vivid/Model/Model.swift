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
    
    override init() {
        super.init()
    }
    
    //MARK: Fetch data from Managed Object
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
    

   //Load data
    
    func loadData() {
        
        var nonSmokingBars = [NonSmokingBar]()
        
        managedObjectContext = dataStack.viewContext
        
        request.returnsObjectsAsFaults = false
        
        do {
            nonSmokingBars = try managedObjectContext.fetch(request) as! [NonSmokingBar]
           
            if nonSmokingBars.count > 0 {
                
                for result in nonSmokingBars {
                    
                    guard let name = result.name, let photos = result.thumbPhotos, let placeTypes = result.placeTypes else {
                        print("Could not unwrap properly name, photos or place_types")
                        return
                    }
                    
                    print("Bar name: \(name)")
                    print("Photos: \(photos)")
                    print("Places Types: \(placeTypes)")

                }
            }
        } catch {
            print("Could not load data from database: \(error.localizedDescription)")
        }

    }

   //Load results in an array
    
    func loadDataInArray() -> [NonSmokingBar] {
        
        var nonSmokingBars = [NonSmokingBar]()
        
        managedObjectContext = dataStack.viewContext
        
        request.returnsObjectsAsFaults = false
        
        do {
            nonSmokingBars = try managedObjectContext.fetch(request) as! [NonSmokingBar]
            print("Nº in Array: \(nonSmokingBars.count)")
     
        } catch {
            print("Could not load data from database: \(error.localizedDescription)")
        }
        
        return nonSmokingBars
    }
    
    func addPlaceIdInd(placeId: String) {
        
        let modelResults = fetchManagedObject()
        
        guard !modelResults.isEmpty else {
            print("modelResults in empty")
            return
        }
        
        for result in modelResults as! [NSManagedObject] {
            
            guard let name = result.value(forKey: "name") as? String else {
                print("Could not find name as String in Model")
                return
            }
            
            if name == "OFFSIDE Pub & Whisky Bar" {
                result.setValue(placeId, forKey: "placeId")
                print("Place Id: \(placeId) saved for bar: \(name)")
                
                do {
                    try managedObjectContext.save()
                    print("PLACE ID UPDATED")
                } catch {
                    print("We could not save correctly the PLACE ID into context")
                }
            }
        }
    }

    func addData() {
        
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
    
    
    func savePlaceIDs() {
        
        var placeIDSaved = 0
        
        let results = fetchManagedObject()
        
        guard results.count > 0 else {
            print("Results is empty")
            return
        }
        
        for result in results as! [NSManagedObject] {
            
            if let barName = result.value(forKey: "name") as? String, let barAddress = result.value(forKey: "address") as? String {
                
                GMSClient.sharedInstance().getPlaceID(barName, barAddress) { (success, placeID, error) in
                    
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

    func updateData() {
        
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
    func deleteData() {
        
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
    
    
    //MARK: Export JSON from model - ERROR: I cannot get a json object
    func exportDataAsJSON () {
        
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
    
    func getPhotosDictionary(_ fetchedResults: [NonSmokingBar]) -> [String:Any] {
        
        var photosDictionary = [String:Any]()
        
        for object in fetchedResults {
            
            if let photosData = object.thumbPhotos, let barName = object.name {
                
                let photosArray = NSKeyedUnarchiver.unarchiveObject(with: photosData as Data) as? [String]
                
                photosDictionary[barName] = photosArray
      
            } else {
                print("Could not find photos or name in fetchedObject")
            }
        }
        return photosDictionary
    }
    
    func getPhotosArray(photos: NSData) -> [String] {
        
        let photosArray = NSKeyedUnarchiver.unarchiveObject(with: photos as Data) as? [String]
        if let photosArray = photosArray {
            return photosArray
        } else {
            print("Could not convert photos as array of Strings")
            return []
        }  
    }
    
    func getPlaceIDDictionary() -> [String:String] {
        
        var placeIDDictionary: [String:String] = [:]
        
        let modelResults = fetchManagedObject()
        
        guard !modelResults.isEmpty else {
            print("modelResultIsEmpty")
            return [:]
        }
        
        for result in modelResults as! [NonSmokingBar] {
            
            if let name = result.value(forKey: "name") as? String, let placeID = result.value(forKey: "placeId") as? String {
                placeIDDictionary[name] = placeID
            } else {
                print(result.name ?? "No name")
                print(result.placeId ?? "No placeID")
                print("Could not find name or placeID in results")
            }
            
        }
        return placeIDDictionary
    }
    
    func storeLocation(_ modelResult: NSManagedObject,_ location: String) {
        
        modelResult.setValue(location, forKey: "location")
        
        do {
            try self.managedObjectContext.save()
        } catch {
            print("Could not save correctly location into context")
        }
    }
    
    func storeRating(_ modelResult: NSManagedObject,_ rating: Int) {
        
        modelResult.setValue(rating, forKey: "rating")
        
        do {
            try self.managedObjectContext.save()
        } catch {
            print("Could not save correctly rating into context")
        }
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
    
    func storeThumbPhotos(_ modelResult: NSManagedObject,_ photos: [String]) {
        
        //Set value and save in Model
        let data = NSKeyedArchiver.archivedData(withRootObject: photos)
        
        modelResult.setValue(data, forKey: "thumbPhotos")
        
        do {
            try self.managedObjectContext.save()
            print("Thumb photos saved")
        } catch {
            print("Could not save correctly thumb photos into context")
        }
    }
    
    func storeLargePhotos(_ modelResult: NSManagedObject,_ photos: [String]) {
        
        //Set value and save in Model
        let data = NSKeyedArchiver.archivedData(withRootObject: photos)
        
        modelResult.setValue(data, forKey: "largePhotos")
        
        do {
            try self.managedObjectContext.save()
            print("Large photos saved")
        } catch {
            print("Could not save correctly large photos into context")
        }
    }
    
    //MARK: Update Core Data Model from GMS Api
    func storeDatainModelFromGMSApi(_ results: [[String:Any]]) {
        
        print("Store data method called")
        var matchedBars = 0
        
        let modelResults = fetchManagedObject()
        
        for result in results {
            
            guard let name = result["name"] as? String, let _ = result["location"] as? String, let _ = result["rating"] as? Int, let _ = result["placeTypes"] as? [String], let largePhotos = result["largePhotos"] as? [String], let thumbPhotos = result["thumbPhotos"] as? [String] else {
                print("Could not find name, location, rating, placeTypes, thumbPhotos or largePhotos in results")
                return
            }
        
            for modelResult in modelResults as! [NSManagedObject] {
                
                guard let modelName = modelResult.value(forKey: "name") as? String else {
                    print("Could not find modelName as String")
                    return
                }
                
                //In this case we are only storing the photo arrays
                if modelName == name {
                    matchedBars += 1
                    storeThumbPhotos(modelResult, thumbPhotos)
                    storeLargePhotos(modelResult, largePhotos)
                }
            }
        }
        
        let when = DispatchTime.now() + 3
        DispatchQueue.main.asyncAfter(deadline: when) {
            print("Matched Bars: \(matchedBars)")
        }
    }
    
    // MARK: Store Data General call
    func storeDataGeneralCall() {
    
            GMSClient.sharedInstance().getDataFromGMSApi() { (results, error) in
            
            guard error == nil else {
                print(error!)
                return
            }
            
            guard let results = results else {
                print("Could not unwrap results from completion handler")
                return
            }
            
            self.storeDatainModelFromGMSApi(results)
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
