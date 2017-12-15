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
    
    var image: UIImage?
    var imageURL: String?
    let id: Int
    let shop_id: Int
    let name: String
    let description: String
    let stock: Int
    let price: Int
    let rating: Double
    
    init(){
        self.id = 0
        self.shop_id = 0
        self.name = "name"
        self.description = "description"
        self.stock = 0
        self.price = 0
        self.rating = 0
        self.imageURL = "imageURL"
    }
    
    init(id:Int, shop_id:Int, name:String, description:String, stock:Int, price:Int, rating:Double, imageURL:String) {
        self.id = id
        self.shop_id = shop_id
        self.name = name
        self.description = description
        self.stock = stock
        self.price = price
        self.rating = rating
        self.imageURL = imageURL
    }
    
//    func imageURL() -> URL? {
//        if let url =  URL(string: "http://shopeeng.000webhostapp.com/shop/product/\(id).jpg") {
//            return url
//        }
//        return nil
//    }
}

func ==(lhs: ProductModel, rhs: ProductModel) -> Bool {
    return lhs.id == rhs.id
}
