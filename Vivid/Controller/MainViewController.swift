//
//  MainViewController.swift
//  Vivid
//
//  Created by Celia Gómez de Villavedón on 05/07/2017.
//  Copyright © 2017 Celia Gómez de Villavedón Pedrosa. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    var data = [NonSmokingBar]()
    
    //MARK: Outlets
    @IBOutlet weak var containerViewMap: UIView!
    @IBOutlet weak var containerViewTable: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        searchView.isHidden = true

        // Do any additional setup after loading the view.
    }
    
    @IBAction func searchInNeighbourhood(_ sender: Any) {
        
        if searchView.isHidden {
            searchView.isHidden = false
        } else {
            searchView.isHidden = true
        }
    }
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            UIView.animate(withDuration: 0.5, animations: {
                self.containerViewMap.alpha = 1
                self.containerViewTable.alpha = 0
                self.searchButton.isEnabled = true
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.containerViewMap.alpha = 0
                self.containerViewTable.alpha = 1
                self.searchButton.isEnabled = false
                self.searchView.isHidden = true
            })
        }
    }
}
