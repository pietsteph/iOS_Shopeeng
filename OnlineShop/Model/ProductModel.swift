//
//  ProductModel.swift
//  OnlineShop
//
//  Created by Pieter Stephenson on 04/12/17.
//  Copyright © 2017 Pieter Stephenson. All rights reserved.
//

import Foundation
import UIKit

class ProductModel : Equatable{
    
    var imageURL: String
    let id: Int
    let name: String
    let description: String
    let price: Int
    let image: String
    let total_images: Int
    let stock: Int
    let view: Int
    let sold: Int
    let condition: String
    let heavy: Double
    let is_insurance: Int
    let shop_id: Int
    let is_enabled: Int
    let rating: Double
    let review: Int
    
    init(){
        self.id = 0
        self.shop_id = 0
        self.name = "name"
        self.description = "description"
        self.stock = 0
        self.price = 0
        self.rating = 0
        self.imageURL = "imageURL"
        self.image = "image"
        self.total_images = 0
        self.view = 0
        self.sold = 0
        self.heavy = 0.0
        self.condition = "condition"
        self.is_insurance = 0
        self.is_enabled = 0
        self.review = 0
    }
    
    init(id:Int, shop_id:Int, name:String, description:String, stock:Int, price:Int, rating:Double, imageURL:String, image:String, total_images:Int, view:Int, sold:Int, heavy:Double, condition:String, is_insurance:Int, is_enabled:Int, review:Int) {
        self.id = id
        self.shop_id = shop_id
        self.name = name
        self.description = description
        self.stock = stock
        self.price = price
        self.rating = rating
        self.imageURL = imageURL
        self.image = "image"
        self.total_images = total_images
        self.view = view
        self.sold = sold
        self.heavy = heavy
        self.condition = condition
        self.is_insurance = is_insurance
        self.is_enabled = is_enabled
        self.review = review
    }
}

func ==(lhs: ProductModel, rhs: ProductModel) -> Bool {
    return lhs.id == rhs.id
}
