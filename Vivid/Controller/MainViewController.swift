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
    
    private lazy var mapViewController: MapViewController = {
        
        // Load storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        
        self.add(asChildViewController: viewController)
        
        return viewController
        
    }()
    
    private lazy var resultsTableViewController: ResultsTableViewController = {
        
        // Load storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "ResultsTableViewController") as! ResultsTableViewController
        
        self.add(asChildViewController: viewController)
        
        return viewController
        
    }()
    
    private lazy var neighbourhoodPickerViewController: NeighbourhoodPickerViewController = {
        
        // Load storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "NeighbourhoodPickerViewController") as! NeighbourhoodPickerViewController
        
        self.add(asChildViewController: viewController)
        
        return viewController
        
    }()
    
    private func add(asChildViewController viewController: UIViewController) {
        //Add Child View Controller
        addChildViewController(viewController)
        
        //Add Child View as Subview
        view.addSubview(viewController.view)
        
        //Configure Child View
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        //Notify Child View Controller
        viewController.didMove(toParentViewController: self)
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        //Notify Child View Controller
        viewController.willMove(toParentViewController: nil)
        
        //Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        //Notify Child View Controller
        viewController.removeFromParentViewController()
    }
    
    func userDidMadeSearchQuery(data: String?) {
        print("userDidMadeSearchQuery called")
        if let data = data {
            print("Received text: \(data)")
        } else {
            print("No results")
        }
    }
    
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
                self.remove(asChildViewController: self.resultsTableViewController)
                self.add(asChildViewController: self.mapViewController)
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.containerViewMap.alpha = 0
                self.containerViewTable.alpha = 1
                self.searchButton.isEnabled = false
                self.searchView.isHidden = true
                self.remove(asChildViewController: self.mapViewController)
                self.add(asChildViewController: self.resultsTableViewController)
            })
        }
    }
}
