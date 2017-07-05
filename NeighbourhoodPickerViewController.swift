//
//  NeighbourhoodPickerViewController.swift
//  Vivid
//
//  Created by Celia Gómez de Villavedón on 03/07/2017.
//  Copyright © 2017 Celia Gómez de Villavedón Pedrosa. All rights reserved.
//

import UIKit
import MapKit


//MARK: Neighbourhood enumeration

enum Neighbourhood: String {
    case currentLocation = "Current location", neukölln = "Neukölln", kreuzberg = "Kreuzberg", mitte = "Mitte"
}

//MARK: NeighbourhoodPickerViewControllerDelegate

protocol NeighbourhoodPickerViewControllerDelegate {
    func neighbourhoodPicker(_ neighbourPicker: NeighbourhoodPickerViewController, didPickNeighbourhood neighbourhood: Neighbourhood?)
}

//MARK: NeighbourhoodPickerViewController: UIViewController

class NeighbourhoodPickerViewController: UIViewController {
    
    //the delegate will typically be a view controller, waiting for the NeighbourhoodPicker to return a Neighbourhood
    var delegate: NeighbourhoodPickerViewControllerDelegate?
    
    //the most recent data download task. We keep a reference to it so that it can be cancelled every time the search changes
    var searchTask: URLSessionDataTask?
    
    //MARK: Outlets
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
