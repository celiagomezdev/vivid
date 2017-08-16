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
    
    //MARK: Import data into database
    func importListData() {
        
        self.getDataWith { (json, error) in
            
            guard error == nil else { print("Could not import the JSON to NonSmoking barModel"); return }
            
            if let jsonResult = json?["results"] as? [[String:Any]] {
                
                self.dataStack.sync(jsonResult, inEntityNamed: "NonSmokingBar") { error in
                    guard error == nil else { print("Could not import the JSON to NonSmoking barModel"); return }
                    print("SAVED \(jsonResult.count) in data base")
                }
                
            } else {
                print("Could not get data as [[String:Any]]")
            }
        }
        
        print("importListData called")
        
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
    
    
    
    //MARK: Update data in our data base
    func updateNonSmokingBarsModelFromGMSApi() {
        
        //Accesing Model
        
        managedObjectContext = dataStack.viewContext
        
        request.returnsObjectsAsFaults = false
        
        do {
            
            let results = try managedObjectContext.fetch(request)
            
            if results.count > 0 {
                
                print("nº in Database: \(results.count)")
                var matchedItemsCount = 0
                
                for result in results as! [NSManagedObject] {
                    
                    if let barName = result.value(forKey: "name") as? String, let placeID = result.value(forKey: "placeId") as? String {
                        
                        self.getPlaceDetails(placeID) { (results, error) in
                            
                            if let error = error {
                                
                                print("We could not get place details. \(error.localizedDescription)")
                                
                            } else {
                                
                                if let result = results?["result"] as? [String:Any] {
                                    
                                    if let GMSPlaceName = result["name"] as? String {
                                        matchedItemsCount += 1
                                        print("DETAILS MATCHED. DatabaseName: \(barName) vs GMSName: \(GMSPlaceName)")
                                    } else {
                                        print("Could not find 'name' in result")
                                    }
                                } else {
                                    if let status = results?["status"] as? String {
                                        print("Had error for place \(barName), with \(placeID): \(status)")
                                    }
                                }
                            }
                        }
                    }
                }
                
                let when = DispatchTime.now() + 2
                DispatchQueue.main.asyncAfter(deadline: when) {
                    print("Nº total matches: \(matchedItemsCount)")
                }
            }
        } catch {
                    print("We couldn't save correctly the data into context")
                }
            }

//                        do {
//                            try self.managedObjectContext.save()
//                            
//                        } catch {
//                            print("We couldn't save correctly the data into context")
//                        }

    
 
    
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
    
    
    //MARK: Helper Editable methods for Data Base
    
    //Edit values of an attribute in core data
    func addManually() {
        
        managedObjectContext = dataStack.viewContext
        
        request.returnsObjectsAsFaults = false
        
        do {
            
            let results = try managedObjectContext.fetch(request)
            print("nº in Database: \(results.count)")
            
            if results.count > 0 {
                
                for result in results as! [NSManagedObject] {
                    
                    if let barName = result.value(forKey: "name") as? String {
                        
                        switch barName {
                            
                        case "Altes Europa":
                            print("SAVED place id for bar: \(barName)")
                            result.setValue("fc28d9479fcf525a0ce246f72b078097616aa6f4", forKey: "placeId")
                        case "K-Fetisch":
                            print("SAVED place id for bar: \(barName)")
                            result.setValue("10d4ebad03c995f33bb89c2bff7415759e463fde", forKey: "placeId")
                        case "Café Pförtner":
                            print("SAVED place id for bar: \(barName)")
                            result.setValue("fb8f5b2ce90bfdd428df952571628d3bfadc2da1", forKey: "placeId")
                        case "Mano":
                            print("SAVED place id for bar: \(barName)")
                            result.setValue("1c9b7fe4265f78c24e2515fecffe30d8937c8161", forKey: "placeId")
                        case "Ungeheuer":
                            print("SAVED place id for bar: \(barName)")
                            result.setValue("0ed35d2d128b2677f788b6e28e4499a77f05ff2c", forKey: "placeId")
                        case "Wolf Kino":
                            print("SAVED place id for bar: \(barName)")
                            result.setValue("d2d0547e5716dac8209c38d59a5ece582afb2c99", forKey: "placeId")
                        case "Hops & Barley":
                            print("SAVED place id for bar: \(barName)")
                            result.setValue("281111bbe675bdc6745cb3912f6a4e53aa2a4e3a", forKey: "placeId")
                        case "Laika":
                            print("SAVED place id for bar: \(barName)")
                            result.setValue("5fac58dd8d8f1c4aeae3930c23dab97935d270da", forKey: "placeId")
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
    
    func loadData() {
        
        managedObjectContext = dataStack.viewContext
        
        request.returnsObjectsAsFaults = false
        
        do {
            nonSmokingBars = try managedObjectContext.fetch(request) as! [NonSmokingBar]
            print("Nº in Array: \(nonSmokingBars.count)")
            
            var barsWithPlaceID = 0
            
            for result in nonSmokingBars {
                if let databaseName = result.name {
                    if result.placeId == nil {
                        print("Name: \(databaseName), no place_id")
                    } else {
                        barsWithPlaceID += 1
                        print("Name: \(databaseName), place_id: \(result.placeId!)")
                    }
                } else {
                    print("No name in our Array from database")
                }
            }
            
            let when = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: when) {
                print("Nº total bars: \(self.nonSmokingBars.count)")
                print("Nº bars with place id: \(barsWithPlaceID)")
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
        }  catch {
            print("We couldn't save correctly the data into context")
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
    
    
    


    // MARK: Shared Instance

    class func sharedInstance() -> Model {
        struct Singleton {
            static var sharedInstance = Model()
        }
        return Singleton.sharedInstance
    }
}
