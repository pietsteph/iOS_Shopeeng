//
//  SectionHeaderCollectionReusableView.swift
//  OnlineShop
//
//  Created by Pieter Stephenson on 02/12/17.
//  Copyright © 2017 Pieter Stephenson. All rights reserved.
//

import UIKit

class SectionHeaderCollectionReusableView: UICollectionReusableView {
        
    @IBOutlet weak var headerLabel: UILabel!
    
    var header:String! {
        didSet{
            headerLabel.text = header
        }
    }
}
