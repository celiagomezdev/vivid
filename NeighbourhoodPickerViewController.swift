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



//MARK: NeighbourhoodPickerViewController: UIViewController

class NeighbourhoodPickerViewController: UIViewController, UITextFieldDelegate {

    //MARK: Outlets
    @IBOutlet weak var mySearchTextField: SearchTextField!
    
    var queryText: String?
    var neighbourhoods: [String]!
    var userLocation: String?
    var currentLocation: CLLocation!
    
    //MARK: Neighbourhood enumeration
    
    enum Neighbourhood: String {
        case currentLocation = "Current location", neukölln = "Neukölln", kreuzberg = "Kreuzberg", mitte = "Mitte"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mySearchTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(locationUpdateNotification), name: Notification.Name("UserLocationNotification"), object: nil)
        
        neighbourhoods = [Neighbourhood.currentLocation.rawValue, Neighbourhood.kreuzberg.rawValue, Neighbourhood.neukölln.rawValue, Neighbourhood.mitte.rawValue]
        
        neighbourhoodPicker(neighbourhoods: neighbourhoods)

    }
    
    func locationUpdateNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo?["location"] as? CLLocation {
            self.currentLocation = userInfo
            self.userLocation = "\(userInfo.coordinate.latitude), \(userInfo.coordinate.longitude)"
        }
    }
    
    //MARK: neigbourhoodPicker
    
    func neighbourhoodPicker(neighbourhoods: [String]) {
        
        //TODO implement completionHandler
        
        if (mySearchTextField) != nil {
            mySearchTextField.filterStrings(neighbourhoods)
            mySearchTextField.theme.font = UIFont.systemFont(ofSize:14)
            mySearchTextField.highlightAttributes = [NSFontAttributeName:UIFont.boldSystemFont(ofSize:14)]
        } else {
            print("No search text field")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text != nil {
            queryText = textField.text
            print("\(String(describing: queryText!))")
            userSelection()
        } else {
            print("Error: textFieldDidEndEditing")
        }
    }
    
    func userSelection() {
        if queryText == "Current location" {
            print(userLocation ?? "No location")
        }
    }
}

extension NeighbourhoodPickerViewController {
    
    struct Neighbourhoods {
        
        static let Neukölln = "52.479209, 13.437409"
        static let Kreuzberg = "52.499248, 13.403765"
        static let Mitte = "52.521785, 13.401039"
    
    }
    
}
