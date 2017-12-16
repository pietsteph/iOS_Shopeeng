//
//  ShopModel.swift
//  OnlineShop
//
//  Created by Pieter Stephenson on 17/12/17.
//  Copyright © 2017 Pieter Stephenson. All rights reserved.
//

import Foundation
import UIKit

class ShopModel : Equatable{
    
    let id: Int
    let name: String
    let phone: String
    let description: String
    let user_id: Int
    let is_enabled: Int
    
    init(){
        self.id = 0
        self.name = "name"
        self.phone = "phone"
        self.description = "description"
        self.user_id = 0
        self.is_enabled = 0
    }
    
    init(id:Int, name:String, phone:String, description:String, user_id:Int, is_enabled:Int) {
        self.id = id
        self.name = name
        self.phone = phone
        self.description = description
        self.user_id = user_id
        self.is_enabled = is_enabled
    }
}

func ==(lhs: ShopModel, rhs: ShopModel) -> Bool {
    return lhs.id == rhs.id
}
