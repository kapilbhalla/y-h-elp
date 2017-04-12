//
//  DropDownCell.swift
//  Yelp
//
//  Created by Bhalla, Kapil on 4/10/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

// This class represents the drop down table view cell for rows that need the drop down style.


protocol DropDownCellDelegate {
    func checkboxChanged(cell: DropDownCell, isChecked: Bool)
}

class DropDownCell: UITableViewCell {

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    // Why is this required
    var cellIndexPath: IndexPath!
    
    var delegate: DropDownCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
