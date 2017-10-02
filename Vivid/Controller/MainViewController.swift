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
    
    var sentText = "Hola Caracola"
    
    private lazy var mapViewController: MapViewController = {
        
        // Load storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        
        self.add(asChildViewController: viewController, containerView: containerSwitchView)
        
        return viewController
        
    }()
    
    private lazy var resultsTableViewController: ResultsTableViewController = {
        
        // Load storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "ResultsTableViewController") as! ResultsTableViewController
        
        self.add(asChildViewController: viewController, containerView: containerSwitchView)
        
        return viewController
        
    }()
    
    private lazy var neighbourhoodPickerViewController: NeighbourhoodPickerViewController = {
        
        // Load storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "NeighbourhoodPickerViewController") as! NeighbourhoodPickerViewController
        
        self.add(asChildViewController: viewController, containerView: searchView)
        
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
    
    private func add(asChildViewController viewController: UIViewController, containerView: UIView) {
        
        //Add Child View Controller
        addChildViewController(viewController)
        
        //Add Child View as Subview
        containerView.addSubview(viewController.view)
        
        //Configure Child View
        viewController.view.frame = containerView.bounds
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

    private func updateView() {
        if segmentedControl.selectedSegmentIndex == 0 {
            remove(asChildViewController: resultsTableViewController)
            add(asChildViewController: mapViewController, containerView: containerSwitchView)
        } else {
            searchButton.isEnabled = false
            searchView.isHidden = true
            remove(asChildViewController: mapViewController)
            add(asChildViewController: resultsTableViewController, containerView: containerSwitchView)
        }
    }

    @IBAction func searchInNeighbourhood(_ sender: Any) {
        
        if searchView.isHidden {
            searchView.isHidden = false
            add(asChildViewController: neighbourhoodPickerViewController, containerView: searchView)
        } else {
            searchView.isHidden = true
            remove(asChildViewController: neighbourhoodPickerViewController)
        }
    }
}
