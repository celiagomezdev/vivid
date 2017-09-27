//
//  ResultsTableViewController.swift
//  Vivid
//
//  Created by Celia Gómez de Villavedón on 26/08/2017.
//  Copyright © 2017 Celia Gómez de Villavedón Pedrosa. All rights reserved.
//

import UIKit
import Sync


class ResultsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var dataStack = Model.sharedInstance().dataStack
    var nonSmokingBars = [NonSmokingBar]()
    var managedObjectContext: NSManagedObjectContext!
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "NonSmokingBar")
    var photosDictionary: [String:Any] = [:]
    var filteredSmokingBars = [NonSmokingBar]()
    
    @IBOutlet var resultsTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nonSmokingBars = Model.sharedInstance().loadDataInArray()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("ResultsViewController Will Appear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("ResultsViewController Will Disappear")
    }
    

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
 
        return self.filteredSmokingBars.count
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "barCell", for: indexPath) as? ResultsTableViewCell else {
            fatalError("The dequeued cell is not an instance of ResultsTableViewCell.")
        }
        
        let bar = filteredSmokingBars[indexPath.row]
        
 
        guard let barName = bar.name, let barAddress = bar.address, let barThumbPhotos = bar.thumbPhotos else {
            fatalError("Could not unwrapp barName, barAddresss or barImage")
        }
        
        var barThumbPhotosInArray = Model.sharedInstance().getPhotosArray(photos: barThumbPhotos)
     
        cell.barNameLabel?.text = barName
        cell.barAddressLabel?.text = barAddress
        
        //Extract UIImage from URL async
        
        if !barThumbPhotosInArray.isEmpty {
            
            let downloadQueue = DispatchQueue(label: "download", attributes: [])
            
            let firstImageURL = barThumbPhotosInArray[0]
            
            //Download image in the background - GCD
            downloadQueue.async {
                
                if let url = URL(string: firstImageURL), let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    
                    //Display the image in the main thread - GCD
                    DispatchQueue.main.async(execute: { () -> Void in
                        cell.barImage.image = image
                    })
                }
            }
        } else {
            print("Used default photo for bar: \(barName)")
            let url = URL(string: "https://c2.staticflickr.com/4/3766/13275992763_53485b6dc5_b.jpg")
            let data = try? Data(contentsOf: url!)
            cell.barImage.image = UIImage(data: data!)
        }
        return cell
    }

}
