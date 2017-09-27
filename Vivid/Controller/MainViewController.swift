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
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var containerSwitchView: UIView!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchView.isHidden = true

        setupView()
    }
    
    private func setupView() {
        setupSegmentedControl()
        
        updateView()
    }
    
    private func setupSegmentedControl() {
        //Configure Segmented Control
        segmentedControl.removeAllSegments()
        segmentedControl.insertSegment(withTitle: "Map", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "List", at: 1, animated: false)
        segmentedControl.addTarget(self, action: #selector(selectionDidChange(_:)), for: .valueChanged)
        
        //Select First Segment
        segmentedControl.selectedSegmentIndex = 0
    }
    
    @objc func selectionDidChange(_ sender: UISegmentedControl) {
        updateView()
    }
    
    private func add(asChildViewController viewController: UIViewController) {
        
        //Add Child View Controller
        addChildViewController(viewController)
        
        //Add Child View as Subview
        self.containerSwitchView.addSubview(viewController.view)
        
        //Configure Child View
        viewController.view.frame = self.containerSwitchView.bounds
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
    
    private func updateView() {
        if segmentedControl.selectedSegmentIndex == 0 {
            remove(asChildViewController: resultsTableViewController)
            add(asChildViewController: mapViewController)
        } else {
            remove(asChildViewController: mapViewController)
            add(asChildViewController: resultsTableViewController)
        }
    }

    @IBAction func searchInNeighbourhood(_ sender: Any) {
        
        if searchView.isHidden {
            searchView.isHidden = false
        } else {
            searchView.isHidden = true
        }
    }
}
