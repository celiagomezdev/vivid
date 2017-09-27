//
//  NeighbourhoodPickerViewController.swift
//  Vivid
//
//  Created by Celia Gómez de Villavedón on 03/07/2017.
//  Copyright © 2017 Celia Gómez de Villavedón Pedrosa. All rights reserved.
//

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
    var nonSmokingBars = [NonSmokingBar]()
    var filteredSmokingBars = [NonSmokingBar]()
    var queryText = String()
    
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
        
        //Call method to populate array with all the bars from Model
        nonSmokingBars = Model.sharedInstance().loadDataInArray()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("Neighbourhood View Controller Will Appear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("Neighbourhood View Controller Will Disappear")
    }
    
    @objc func locationUpdateNotification(notification: NSNotification) {
        
        if let userInfo = notification.userInfo?["location"] as? CLLocation {
            self.userLocation = "\(userInfo.coordinate.latitude),\(userInfo.coordinate.longitude)"
        }
    }
    
    //MARK: neigbourhoodPicker helper method
    
    func neighbourhoodPickerConfig(neighbourhoods: [String]) {
        
        mySearchTextField.filterStrings(neighbourhoods)
        mySearchTextField.theme.font = UIFont.systemFont(ofSize:14)
        mySearchTextField.highlightAttributes = [NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue):UIFont.boldSystemFont(ofSize:14)]
        mySearchTextField.autocorrectionType = .no
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
//    MARK: getPlaces methods depending what user chooses
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let searchString = textField.text {
            
            if neighbourhoods.contains(searchString) {
                
                if searchString == "Current location" {
                    if let userLocation = userLocation {
                        print("User chose 'Current Location': \(userLocation)")
                    }
                } else {
                    print("User chose the neighbourhood: \(searchString)")
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

    
    @IBAction func sendText(_ sender: Any) {
        
        guard let data = mySearchTextField.text else {
            print("We couldn't receive the data")
            return
        }
        
        self.queryText = data
    }
    
    func getBarsForSearchString(_ searchString: String, completion: @escaping (_ result: [NonSmokingBar]?,_ error: NSError?) -> Void) {
        
        var filteredSmokingBars = [NonSmokingBar]()
        
        for item in nonSmokingBars {
            if item.neighbourhood == searchString {
                filteredSmokingBars.append(item)
                completion(filteredSmokingBars, nil)
            } else {
                completion(nil, NSError(domain: "getBarsForStringSearch filtering", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not get bars for the user searchString"]))
            }
        }
    }
}

