//
//  Shopeeng.swift
//  OnlineShop
//
//  Created by Pieter Stephenson on 24/11/17.
//  Copyright © 2017 Pieter Stephenson. All rights reserved.
//

import Foundation
import UIKit

struct Login:Decodable{
    let id: Int?
    let role: String?
    let api_token: String?
    let shop_id: Int?
    let errors: RegisterFields?
}

struct Register:Decodable{
    let id: Int?
    let role: String?
    let api_token: String?
    let shop_id: Int?
    let message: String?
    let errors: RegisterFields?
}

struct RegisterFields:Decodable{
    let name: [String]?
    let email: [String]?
    let password: [String]?
    let phone: [String]?
    let birth: [String]?
    let gender: [String]?
}

struct User:Decodable{
    let id: Int?
    let name: String?
    let email: String?
    let phone: String?
    let birth: String?
    let gender: String?
    let role: String?
    let api_token: String?
}

struct HomeProducts:Decodable{
    let popular:[Product]
    let new:[Product]
}

struct Product:Decodable{
    let id: Int?
    let shop_id: Int?
    let name: String?
    let description: String?
    let stock: Int?
    let price: Int?
    let rate: Double?
}

struct Shop:Decodable{
    let id: Int?
    let user_id: Int?
    let phone: String?
}

struct Logout:Decodable{
    let info: String?
    let error: String?
}

class Shopeeng{
    
//    let ipAddress = "http://gunnylab.ddns.net:8080/api/"
    let ipAddress = "http://192.168.0.16:8080/api/"
    
    func homeCollection(completion: @escaping (_ results: [[ProductModel]]) -> Void){
        guard let myUrl = URL(string: URL_POPULAR_NEW_PRODUCTS) else { return }
        
        URLSession.shared.dataTask(with: myUrl) {
            (data, response, error) in
            
            if error != nil
            {
                print("error=\(error!)")
                return
            }
            
            guard let data = data else { return }
            
            var popular_new_products = [[ProductModel]]()
            
            do {
                let json = try JSONDecoder().decode(HomeProducts.self, from: data)
                
                var popular = [ProductModel]()
                var new = [ProductModel]()
                
                for product in json.popular {
                    guard let id = product.id,
                        let shop_id = product.shop_id,
                        let name = product.name,
                        let description = product.description,
                        let stock = product.stock,
                        let price = product.price,
                        let rating = product.rate else {
                            break
                    }

                    let decodedProduct = ProductModel(id: id, shop_id: shop_id, name: name, description: description, stock: stock, price: price, rating: rating, imageURL: "\(self.URL_PRODUCT_IMAGE)\(id).jpg")

                    popular.append(decodedProduct)
                }
                
                for product in json.new {
                    guard let id = product.id,
                        let shop_id = product.shop_id,
                        let name = product.name,
                        let description = product.description,
                        let stock = product.stock,
                        let price = product.price,
                        let rating = product.rate else {
                            break
                    }
                    
                    let decodedProduct = ProductModel(id: id, shop_id: shop_id, name: name, description: description, stock: stock, price: price, rating: rating, imageURL: "\(self.URL_PRODUCT_IMAGE)\(id).jpg")
                    
                    new.append(decodedProduct)
                }
                
                popular_new_products.append(popular)
                popular_new_products.append(new)
            }
            catch{
                print("Error:", error)
                return
            }
            
            OperationQueue.main.addOperation({
                completion(popular_new_products)
            })
        }.resume()
    }
    
    func myProducts(shop_id:Int, completion: @escaping (_ results: [ProductModel]) -> Void){
        let myUrl = URL(string: URL_ALL_PRODUCTS)
        var request = URLRequest(url: myUrl!)
        request.httpMethod = "POST"
        let postString = "shop_id=\(shop_id)";
        request.httpBody = postString.data(using: String.Encoding.utf8);
        
        URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            if error != nil
            {
                print("error=\(error!)")
                return
            }
            
            guard let data = data else {return}
            
            var products = [ProductModel]()
            
            do {
                let json = try JSONDecoder().decode([Product].self, from: data)
                
                for product in json {
                    guard let id = product.id,
                        let shop_id = product.shop_id,
                        let name = product.name,
                        let description = product.description,
                        let stock = product.stock,
                        let price = product.price,
                        let rating = product.rate else {
                            break
                    }

                    let decodedProduct = ProductModel(id: id, shop_id: shop_id, name: name, description: description, stock: stock, price: price, rating: rating, imageURL: "\(self.URL_PRODUCT_IMAGE)\(id).jpg")
                    
                    products.append(decodedProduct)
                }
            }
            catch{
                return
            }
            
            OperationQueue.main.addOperation({
                completion(products)
            })
        }.resume()
    }
    
    func priceToString(integer:Int)->String{
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        let strings = formatter.string(from: NSNumber(value: integer))
        return strings!
    }
    
    let URL_USER_LOGIN = "http://shopeeng.000webhostapp.com/login.php"
    let URL_USER_REGISTER = "http://shopeeng.000webhostapp.com/register.php"
    let URL_SEARCH = "http://shopeeng.000webhostapp.com/search.php"
    let URL_TOPUP = "http://shopeeng.000webhostapp.com/topup.php"
    let URL_POPULAR_NEW_PRODUCTS = "https://shopeeng.000webhostapp.com/home.php"
    
    //User Profile
    let URL_PROFILE = "http://shopeeng.000webhostapp.com/user/profile.php"
    let URL_UPDATE_PROFILE = "http://shopeeng.000webhostapp.com/user/updateprofile.php"
    let URL_PROFILE_PICTURE = "http://shopeeng.000webhostapp.com/user/profile/"
    let URL_UPDATE_PROFILE_PICTURE = "http://shopeeng.000webhostapp.com/user/profilepicture.php"
    let URL_DELETE_PROFILE_PICTURE = "http://shopeeng.000webhostapp.com/user/deleteprofilepicture.php"
    
    //Shop Profile
    let URL_SHOP_PROFILE = "http://shopeeng.000webhostapp.com/shop/profile.php"
    let URL_SHOP_UPDATE_PROFILE = "http://shopeeng.000webhostapp.com/shop/updateprofile.php"
    let URL_SHOP_PROFILE_PICTURE = "http://shopeeng.000webhostapp.com/shop/profile/"
    let URL_SHOP_UPDATE_PROFILE_PICTURE = "http://shopeeng.000webhostapp.com/shop/profilepicture.php"
    let URL_SHOP_DELETE_PROFILE_PICTURE = "http://shopeeng.000webhostapp.com/shop/deleteprofilepicture.php"
    
    //Seller Action
    let URL_ADD_PRODUCT = "http://shopeeng.000webhostapp.com/shop/insertproduct.php"
    let URL_ADD_PRODUCT_IMAGE = "http://shopeeng.000webhostapp.com/shop/insertproductimage.php"
    
    let URL_ALL_PRODUCTS = "http://shopeeng.000webhostapp.com/shop/allproducts.php"
    let URL_PRODUCT_IMAGE = "http://shopeeng.000webhostapp.com/shop/product/"
}
