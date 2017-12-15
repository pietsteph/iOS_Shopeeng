//
//  CreditsTableViewCell.swift
//  OnlineShop
//
//  Created by Pieter Stephenson on 27/11/17.
//  Copyright © 2017 Pieter Stephenson. All rights reserved.
//

import UIKit

class CreditsTableViewCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var topup: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
