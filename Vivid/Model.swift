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
        
        do {
            nonSmokingBars = try managedObjectContext.fetch(request) as! [NonSmokingBar]
            print("Number of bars stored in nonSmokingBars: \(nonSmokingBars.count)")
            
            for result in nonSmokingBars {
                if let databaseName = result.name {
                    if let databaseId = result.placeId {
                        print("name2: \(databaseName), place_id2: \(databaseId)")
                    } else {
                        print("No placeId in our Array from database")
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
            print("nº: \(results.count)")
            
            if results.count > 0 {
                
                for result in results as! [NSManagedObject] {
                    
                    if let barName = result.value(forKey: "name") as? String {
                        
                        let parameters = [GMSClient.ParameterKeys.Radius: "10000", GMSClient.ParameterKeys.Types: "bar", GMSClient.ParameterKeys.Location: GMSClient.Neighbourhoods.Neukölln, "name": "\(barName)"]
                        
                        let _ = GMSClient.sharedInstance().taskForGetMethod(GMSClient.Methods.SearchPlace, parameters: parameters as [String:Any]) { (results, error) in
                            
                            if let error = error {
                                
                                print("ERROR: \(error.localizedDescription)")
                                
                            } else {
                                
                                if let results = results?["results"] as? [[String:Any]] {
                                    
                                    if let firstResultName = results.first?["name"] as? String {
                                        
                                        if let firstResultPlaceId = results.first?["place_id"] as? String {
                                            
                                            print("name1: \(firstResultName), place_id1: \(firstResultPlaceId)")
                                            
                                            if barName == firstResultName {
                                                
                                                result.setValue(firstResultPlaceId, forKey: "placeId")
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
    
    func insertDataManually(context: NSManagedObjectContext) {
        
        let entry1 = NonSmokingBar(context: context)
        
        entry1.name = "SchwuZ"
        entry1.address = "Rollbergstr. 26"
        entry1.neighbourhood = "Neukölln"
        entry1.smokingType = "SepNonSmo"
        
        let entry2 = NonSmokingBar(context: context)
        
        entry2.name = "Südblock"
        entry2.address = "Admiralstraße 1-2"
        entry2.neighbourhood = "Kreuzberg"
        entry2.smokingType = "NonSmo"
        
        let entry3 = NonSmokingBar(context: context)
        
        entry3.name = "Tristeza"
        entry3.address = "Pannierstr.5"
        entry3.neighbourhood = "Neukölln"
        entry3.smokingType = "SepNonSmo"
        entry3.location = "656735762,-287367826"
   
    }

    // MARK: Shared Instance
    
    class func sharedInstance() -> Model {
        struct Singleton {
            static var sharedInstance = Model()
        }
        return Singleton.sharedInstance
    }
}
