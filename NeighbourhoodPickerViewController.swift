//
//  NeighbourhoodPickerViewController.swift
//  Vivid
//
//  Created by Celia Gómez de Villavedón on 03/07/2017.
//  Copyright © 2017 Celia Gómez de Villavedón Pedrosa. All rights reserved.
//

import Foundation
import UIKit
import SearchTextField
import MapKit
import Sync


//MARK: NeighbourhoodPickerViewController: UIViewController

class NeighbourhoodPickerViewController: UIViewController, UITextFieldDelegate {

    //MARK: Outlets
    @IBOutlet weak var mySearchTextField: SearchTextField!
    
    var neighbourhoods: [String]!
    var userLocation: String?
    
    var searchTask: URLSessionDataTask?
    let dataStack = DataStack(modelName: "NonSmokingBarModel")
    var nonSmokingBars = [NonSmokingBar]()
    var managedObjectContext: NSManagedObjectContext!
    
    //MARK: Neighbourhood enumeration
    
    enum Neighbourhood: String {
        case currentLocation = "Current location", neukölln = "Neukölln", kreuzberg = "Kreuzberg", mitte = "Mitte"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mySearchTextField.delegate = self
        
        //Receive Notification from MapViewController - User Location
        NotificationCenter.default.addObserver(self, selector: #selector(locationUpdateNotification), name: Notification.Name("UserLocationNotification"), object: nil)
        
        neighbourhoods = [Neighbourhood.currentLocation.rawValue, Neighbourhood.kreuzberg.rawValue, Neighbourhood.neukölln.rawValue, Neighbourhood.mitte.rawValue]
        
        neighbourhoodPickerConfig(neighbourhoods: neighbourhoods)
//        importListData()
        
        //Accesing
        managedObjectContext = dataStack.viewContext
        
        loadData()

    }
    
    func loadData() {
        
        let nonSmokingBarsRequest: NSFetchRequest<NonSmokingBar> = NonSmokingBar.fetchRequest()
        
        do {
            
            nonSmokingBars = try managedObjectContext.fetch(nonSmokingBarsRequest)
            print("Number of bars in nonSmokingBars: \(nonSmokingBars.count)")
            for each in nonSmokingBars {
                if let barName = each.name {
                    print("Name: \(barName)")
                }
            }
        } catch {
            print("Could not load data from database: \(error.localizedDescription)")
        }
    }
    
    
    func locationUpdateNotification(notification: NSNotification) {

        if let userInfo = notification.userInfo?["location"] as? CLLocation {
            self.userLocation = "\(userInfo.coordinate.latitude),\(userInfo.coordinate.longitude)"
        }
    }
    
    //MARK: neigbourhoodPicker
    
    func neighbourhoodPickerConfig(neighbourhoods: [String]) {
        
        mySearchTextField.filterStrings(neighbourhoods)
            mySearchTextField.theme.font = UIFont.systemFont(ofSize:14)
            mySearchTextField.highlightAttributes = [NSFontAttributeName:UIFont.boldSystemFont(ofSize:14)]
            mySearchTextField.autocorrectionType = .no
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: getPlaces methods depending what user chooses
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let searchText = textField.text {
            
            if neighbourhoods.contains(searchText) {
                
                if searchText == "Current location" {
                    if let userLocation = userLocation {
                        GMSClient.sharedInstance().getPlacesForUserLocation(userLocation)
                    } else {
                        print("We couldn't set the user location")
                    }
                } else {
                    GMSClient.sharedInstance().getPlacesForSelectedNeighbourhood(searchText) { (places, error) in
                        if let places = places {
                            print("Total places: (\(places.count)")
                        } else {
                            print("We don't have yet any places for the selected neighbourhood")
                        }
                    }
                }
            } else {
                
                //Display an alert when text is not recognized
                let alertController = UIAlertController(title: "Oops!", message:
                    "Unrecognized location. Please try again", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
                
                print("The user typed the location incorrectly")
            }
        }
    }
    
    //MARK: Import method for my NonSmokingBars Pre-List
    
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
}


