//
//  ResultsTableViewCell.swift
//  Vivid
//
//  Created by Celia Gómez de Villavedón on 30/08/2017.
//  Copyright © 2017 Celia Gómez de Villavedón Pedrosa. All rights reserved.
//

import UIKit

class ResultsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var barImage: UIImageView!
    
    @IBOutlet weak var barNameLabel: UILabel!
    
    @IBOutlet weak var barAddressLabel: UILabel!

    @IBOutlet weak var distanceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        barNameLabel.sizeToFit()
        barAddressLabel.sizeToFit()
    }

}
