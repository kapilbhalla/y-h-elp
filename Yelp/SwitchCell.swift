//
//  SwitchCell.swift
//  Yelp
//
//  Created by Bhalla, Kapil on 4/8/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit


// This handles the cases when the switch cell is tapped and its value changes.
@objc protocol SwitchCellDelegate {
    
    // [KapiL] Why is this objc required ???
    @objc optional func switchCell(switchCell: SwitchCell, didChangeValue value: Bool)
    
}

class SwitchCell: UITableViewCell {

    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var onSwitch: UISwitch!
    
    // Why is this required
    var cellIndexPath: IndexPath!
    
    weak var delegate: SwitchCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onSwitchTap(_ sender: Any) {
        
        print ("switch value changed")
        delegate?.switchCell?(switchCell: self, didChangeValue: onSwitch.isOn)
    }
}
