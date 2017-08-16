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
                var savedItemsCount = 0
                var notSavedItemsCount = 0
 
                for result in results as! [NSManagedObject] {
                    
                    if let barName = result.value(forKey: "name") as? String, let barAddress = result.value(forKey: "address") as? String {
                        
                        self.getPlaceID(barName, barAddress) { (success, placeID, errorString) in
                            
                            if success {
                                
                                savedItemsCount += 1
                                result.setValue(placeID, forKey: "placeId")
                                
                                do {
                                    try self.managedObjectContext.save()
                                    
                                } catch {
                                    print("We couldn't save correctly the data into context")
                                }
                            } else {
                                notSavedItemsCount += 1
                                print(errorString!)
                            }
                        }
                    }
                }
                
                let when = DispatchTime.now() + 2
                DispatchQueue.main.asyncAfter(deadline: when) {
                    print("Saved items: \(savedItemsCount)")
                    print("Not saved items: \(notSavedItemsCount)")
                }
            }
        } catch {
            print("Could not update the data base: \(error.localizedDescription)")
        }
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
    
    
    //MARK: Editable methods for Data Base
    
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
                        
                    }
                        if barName == "Wolf Kino" {
                            
                        
                        result.setValue(barName + ", Berlin", forKey: "address")
                            
                        }
                        
                        do {
                            try managedObjectContext.save()
                            print("ADDRESS UPDATED")
                        } catch {
                            print("We couldn't save correctly the data into context")
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
            
            for result in nonSmokingBars {
                if let databaseName = result.name {
                    if result.placeId == nil {
                        print("Name: \(databaseName), no place_id")
                    }
                } else {
                    print("No name in our Array from database")
                }
            }
        } catch {
            print("Could not load data from database: \(error.localizedDescription)")
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
