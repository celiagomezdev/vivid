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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nonSmokingBars = Model.sharedInstance().loadDataInArray()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    // MARK: - Table view data source


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
 
        return self.nonSmokingBars.count
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "barCell", for: indexPath) as? ResultsTableViewCell else {
            fatalError("The dequeued cell is not an instance of ResultsTableViewCell.")
        }
        
        let bar = nonSmokingBars[indexPath.row]
        
 
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
  
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
