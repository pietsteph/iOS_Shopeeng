//
//  BalanceTableViewCell.swift
//  OnlineShop
//
//  Created by Pieter Stephenson on 02/12/17.
//  Copyright © 2017 Pieter Stephenson. All rights reserved.
//

import UIKit

class BalanceTableViewCell: UITableViewCell {

    @IBOutlet weak var credits: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
