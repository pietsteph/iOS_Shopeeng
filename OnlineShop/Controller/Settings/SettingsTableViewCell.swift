//
//  SettingsTableViewCell.swift
//  OnlineShop
//
//  Created by Pieter Stephenson on 25/11/17.
//  Copyright © 2017 Pieter Stephenson. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var settingIcon: UIImageView!
    @IBOutlet weak var settingName: UILabel!
    @IBOutlet weak var settingSwitch: UISwitch!
    
    @IBAction func secureApps(_ sender: UISwitch) {
        if sender.isOn{
            UserDefaults.standard.set(true, forKey: "SecureApps")
        }
        else{
            UserDefaults.standard.set(false, forKey: "SecureApps")
        }
        UserDefaults.standard.synchronize()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
