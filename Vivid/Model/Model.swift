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
    

    // MARK: Shared Instance

    class func sharedInstance() -> Model {
        struct Singleton {
            static var sharedInstance = Model()
        }
        return Singleton.sharedInstance
    }
}
