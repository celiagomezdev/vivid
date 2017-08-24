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
    
    func loadResults() {
        
        managedObjectContext = dataStack.viewContext
        
        request.returnsObjectsAsFaults = false
        
        do {
            nonSmokingBars = try managedObjectContext.fetch(request) as! [NonSmokingBar]
            print("Nº in Array: \(nonSmokingBars.count)")
            
            for result in nonSmokingBars {
                if let name = result.name {
                    print("Name: \(name)")
                }
                if let address = result.address {
                    print("Address: \(address)")
                }
                if let location = result.location {
                    print("Location: \(location)")
                }
                if let neighbourhood = result.neighbourhood {
                    print("Neighbourhood: \(neighbourhood)")
                }
                
                print("Postal Code: \(result.postalCode)")
                
                print("Rating: \(result.rating)")
                
                if let placeID = result.placeId {
                    print("Place ID: \(placeID)")
                }
    
                if let checked = result.checked {
                    print("Checked: \(checked)")
                }
                
                if let smokingType = result.smokingType {
                    print("SmokingType: \(smokingType)")
                }
                
                if let photos = result.photos {
                    if let photosStArray = NSKeyedUnarchiver.unarchiveObject(with: photos as Data) as? [String] {
                        print("Photos: \(photosStArray)")
                    } else {
                        print("Could not extract Photos from Model")
                    }
                 }
                
                if let placeTypes = result.place_types {
                    if let placeTypesStArray = NSKeyedUnarchiver.unarchiveObject(with: placeTypes as Data) as? [String] {
                        print("Photos: \(placeTypesStArray)")
                    } else {
                        print("Could not extract Place Types from Model")
                    }
                }
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
