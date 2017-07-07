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



//MARK: NeighbourhoodPickerViewController: UIViewController

class NeighbourhoodPickerViewController: UIViewController, UITextFieldDelegate {

    //MARK: Outlets
    @IBOutlet weak var mySearchTextField: SearchTextField!
    
    var queryText: String?
    var neighbourhoods: [String]!
    
    //MARK: Neighbourhood enumeration
    
    enum Neighbourhood: String {
        case currentLocation = "Current location", neukölln = "Neukölln", kreuzberg = "Kreuzberg", mitte = "Mitte"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mySearchTextField.delegate = self
        
        neighbourhoods = [Neighbourhood.currentLocation.rawValue, Neighbourhood.kreuzberg.rawValue, Neighbourhood.neukölln.rawValue, Neighbourhood.mitte.rawValue]
        
        neighbourhoodPicker(neighbourhoods: neighbourhoods)

        // Do any additional setup after loading the view.
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
        } else {
            print("Error: textFieldDidEndEditing")
        }
    }
    
}
