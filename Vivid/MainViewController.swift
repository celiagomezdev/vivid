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
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        searchView.isHidden = true
//        insertData()
//        fetchData()
        
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func searchInNeighbourhood(_ sender: Any) {
        
        if searchView.isHidden {
            searchView.isHidden = false
        } else {
            searchView.isHidden = true
        }
    }
    
    func insertData() {
        
        let entry1 = NonSmokingBar(context: context)
        
        entry1.name = "SchwuZ"
        entry1.address = "Rollbergstr. 26"
        entry1.neighbourhood = "Neukölln"
        entry1.smokingType = "SepNonSmo"
        
        let entry2 = NonSmokingBar(context: context)
        
        entry2.name = "Südblock"
        entry2.address = "Admiralstraße 1-2"
        entry2.neighbourhood = "Kreuzberg"
        entry2.smokingType = "NonSmo"
        
        let entry3 = NonSmokingBar(context: context)
        
        entry3.name = "Tristeza"
        entry3.address = "Pannierstr.5"
        entry3.neighbourhood = "Neukölln"
        entry3.smokingType = "SepNonSmo"
        entry3.location = "656735762,-287367826"
        
        appDelegate.saveContext()

    }
    
    func fetchData() {
        
        
        do {
            
            data = try context.fetch(NonSmokingBar.fetchRequest())
            print(data)
//            for each in data {
//                print("Name: \(each.name!)")
//            }
        }
        catch let error as NSError {
            print("Could not fetch \(error)")
            // handle error
        }
    }
}
