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

class NeighbourhoodPickerViewController: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var mySearchTextField: SearchTextField!
    
    var queryText: String?
    
    //MARK: Neighbourhood enumeration
    
    enum Neighbourhood: String {
        case currentLocation = "Current location", neukölln = "Neukölln", kreuzberg = "Kreuzberg", mitte = "Mitte"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        neighbourhoodPicker()
        
        // Do any additional setup after loading the view.
    }
    
    func neighbourhoodPicker() {
        
        if (mySearchTextField) != nil {
            mySearchTextField.filterStrings(["Neukölln", "Kreuzberg", "Mitte"])
            mySearchTextField.theme.font = UIFont.systemFont(ofSize:14)
            mySearchTextField.highlightAttributes = [NSFontAttributeName:UIFont.boldSystemFont(ofSize:14)]
            
        } else {
            print("No search text field")
        }
        
    }

    

}
