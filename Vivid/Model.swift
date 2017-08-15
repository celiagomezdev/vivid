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
    
    
    //Load database entries in an array
    
    func loadData() {
        
        managedObjectContext = dataStack.viewContext
        
        request.returnsObjectsAsFaults = false
        
        do {
            nonSmokingBars = try managedObjectContext.fetch(request) as! [NonSmokingBar]
            print("Nº in Array: \(nonSmokingBars.count)")
            
            for result in nonSmokingBars {
                if let databaseName = result.name {
                    if let databasePlaceId = result.placeId {
                        print("name: \(databaseName), place id: \(databasePlaceId)")
                    } else {
                        print("No place ID for name: \(databaseName)")
                    }
                } else {
                    print("No name in our Array from database")
                }
            }
        } catch {
            print("Could not load data from database: \(error.localizedDescription)")
        }
    }
    
    //MARK: Update data in our data base
    func updateNonSmokingBarsModelFromGMSApi() {
        
        //Accesing Model

        managedObjectContext = dataStack.viewContext
        
        request.returnsObjectsAsFaults = false
        
        do {
            
            let results = try managedObjectContext.fetch(request)
            print("nº in Database: \(results.count)")
            
            if results.count > 0 {
                
                for result in results as! [NSManagedObject] {
                    
                    if let barName = result.value(forKey: "name") as? String, let barAddress = result.value(forKey: "address") as? String {
                        
                        let parameters = [GMSClient.ParameterKeys.Radius: "10000", GMSClient.ParameterKeys.Types: "bar", GMSClient.ParameterKeys.Location: GMSClient.Neighbourhoods.Neukölln, "name": "\(barName)"]
                        
                        let _ = GMSClient.sharedInstance().taskForGetMethod(GMSClient.Methods.SearchPlace, parameters: parameters as [String:Any]) { (results, error) in
                            
                            if let error = error {
                                
                                print("ERROR: \(error.localizedDescription)")
                                
                            } else {
                                
                                if let parsedResults = results?["results"] as? [[String:Any]] {
                                    
                                    for item in parsedResults {
                                        
                                        if let itemName = item["name"] as? String, let itemAddress = item["vicinity"] as? String {
                                            
                                            if itemName == barName || itemAddress == barAddress {
                                                
                                                if let itemPlaceId = item["place_id"] as? String {
                                                    
                                                    result.setValue(itemPlaceId, forKey: "placeId")
                                                    print("Place ID Saved: \(itemPlaceId) for barName: \(barName)")
                                                    
                                                    do {
                                                        try self.managedObjectContext.save()
                                                    } catch {
                                                        print("We couldn't save correctly the data into context")
                                                    }
                                                }
                                            } else {
                                                print("Could not match names: Database name: \(barName) vs GMS name: \(itemName) or addresses: \(barAddress) vs GMS name: \(itemAddress)")
                                                
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } catch {
            print("Could not update the data base: \(error.localizedDescription)")
        }
    }
    
    func getPlaceID (_ barName: String?, barAddress: String?, _ completionHanlderForPlaceID: @escaping (_ success: Bool, _ placeID: String?, _ errorString: String?) -> Void) {
        
        let parameters = [GMSClient.ParameterKeys.Radius: "10000", GMSClient.ParameterKeys.Types: "bar", GMSClient.ParameterKeys.Location: GMSClient.Neighbourhoods.Neukölln, "name": "\(barName!)"]
        
        let _ = GMSClient.sharedInstance().taskForGetMethod(GMSClient.Methods.SearchPlace, parameters: parameters as [String:Any]) { (results, error) in
            
            if let error = error {
                
                print("ERROR: \(error.localizedDescription)")
                completionHanlderForPlaceID(false, nil, error.localizedDescription)
                
            } else {
                
                if let parsedResults = results?["results"] as? [[String:Any]] {
                    
                    var itemCount = 0
                    
                    for item in parsedResults {
                        
                        if let itemName = item["name"] as? String, let itemAddress = item["vicinity"] as? String {
                            
                            if itemName.contains(barName!) && itemAddress == barAddress {
                                
                                if let placeID = item["place_id"] as? String {
                                    itemCount += 1
                                    print("Stored Place ID in CompletionHandler: \(placeID) for barName: \(barName!)")
                                    completionHanlderForPlaceID(true, placeID, nil)
                                    
                                } else {
                                    completionHanlderForPlaceID(false, nil, "Could not store Place ID in CompletionHandler for barName: \(barName!) \(String(describing: error?.localizedDescription))")
                                }
                            } else {
                                completionHanlderForPlaceID(false, nil, "Could not match barName and barAddress. Database name: \(barName!) vs GMS name:\(itemName), Database address: \(barAddress!) vs GMS address:\(itemAddress): \(String(describing: error?.localizedDescription))")
                            }
                        } else {
                            completionHanlderForPlaceID(false, nil, "Could not find itemName or itemAddress in parsed results : \(String(describing: error?.localizedDescription))")
                        }
                    }
                    print("Items saved: \(itemCount)")
                }
            }
        }
    }
    
    func adaptAddress() {
        
        managedObjectContext = dataStack.viewContext
        
        request.returnsObjectsAsFaults = false
        
        do {
            
            let results = try managedObjectContext.fetch(request)
            print("nº in Database: \(results.count)")
            
            if results.count > 0 {
                
                for result in results as! [NSManagedObject] {
                    
                    if let barAddress = result.value(forKey: "address") as? String {
                        
                        result.setValue(barAddress + ", Berlin", forKey: "address")
                        
                        do {
                            try self.managedObjectContext.save()
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
    
    // MARK: Shared Instance

    class func sharedInstance() -> Model {
        struct Singleton {
            static var sharedInstance = Model()
        }
        return Singleton.sharedInstance
    }
}
