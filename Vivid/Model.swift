//
//  Model.swift
//  Vivid
//
//  Created by Celia Gómez de Villavedón on 07/08/2017.
//  Copyright © 2017 Celia Gómez de Villavedón Pedrosa. All rights reserved.
//

import Foundation
import UIKit
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

        } catch {
            print("Could not load data from database: \(error.localizedDescription)")
        }
    }
    
    //Update data
    func updateNonSmokingBarsModelFromGMSApi() {
        
        //Accesing Model
        managedObjectContext = dataStack.viewContext

        request.returnsObjectsAsFaults = false
        
        do {
            
            let results = try managedObjectContext.fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let barName = result.value(forKey: "name") as? String {
                        print("Name: \(barName)")
                    }
                }
            }
            
        } catch {
            print("Could not update the data base: \(error.localizedDescription)")
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
