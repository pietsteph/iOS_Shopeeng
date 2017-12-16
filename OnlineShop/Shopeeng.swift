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
    let errors: ErrorFields?
}

struct Register:Decodable{
    let id: Int?
    let role: String?
    let api_token: String?
    let shop_id: Int?
    let message: String?
    let errors: ErrorFields?
}

struct ErrorFields:Decodable{
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
    let shop_id: Int?
    let message: String?
    let errors: ErrorFields?
}

struct Shop:Decodable{
    let id: Int?
    let name: String?
    let phone: String?
    let description: String?
    let user_id: Int?
    let is_enabled: Int?
}

struct HomeProducts:Decodable{
    let popular:[Product]
    let new:[Product]
}

struct Product:Decodable{
    let id: Int?
    let name: String?
    let description: String?
    let price: Int?
    let image: String?
    let total_images: Int?
    let stock: Int?
    let view: Int?
    let sold: Int?
    let condition: String?
    let heavy: Double?
    let is_insurance: Int?
    let shop_id: Int?
    let is_enabled: Int?
    let rating: Double?
    let review: Int?
}

struct Buy:Decodable{
    let success: Bool?
    let warning: String?
}

struct Logout:Decodable{
    let info: String?
    let error: String?
}

class Shopeeng{
    
//    let ipAddress = "http://gunnylab.ddns.net:8080/api/"
    let ipAddress = "http://192.168.0.16:8080/api/"
//    let ipAddress = "http://127.0.0.1:8080/api/"
    
    func homeCollection(completion: @escaping (_ results: [[ProductModel]]) -> Void){
        guard let url = URL(string: "\(self.ipAddress)product"), let token = UserDefaults.standard.string(forKey: "Token") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) {
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
                    let rating = product.rating,
                    let image = product.image,
                    let total_images = product.total_images,
                    let view = product.view, let sold = product.sold, let condition = product.condition,
                    let heavy = product.heavy,let is_insurance = product.is_insurance, let is_enabled = product.is_enabled, let review = product.review else {  break }

                    let decodedProduct = ProductModel(id: id, shop_id: shop_id, name: name, description: description, stock: stock, price: price, rating: rating, imageURL: "\(self.ipAddress)product/image/\(id)", image: image, total_images: total_images, view: view, sold: sold, heavy: heavy, condition: condition, is_insurance: is_insurance, is_enabled: is_enabled, review: review)

                    popular.append(decodedProduct)
                }
                
                for product in json.new {
                    guard let id = product.id,
                        let shop_id = product.shop_id,
                        let name = product.name,
                        let description = product.description,
                        let stock = product.stock,
                        let price = product.price,
                        let rating = product.rating,
                        let image = product.image,
                        let total_images = product.total_images,
                        let view = product.view, let sold = product.sold, let condition = product.condition,
                        let heavy = product.heavy, let is_insurance = product.is_insurance, let is_enabled = product.is_enabled, let review = product.review else { break }
                    
                    let decodedProduct = ProductModel(id: id, shop_id: shop_id, name: name, description: description, stock: stock, price: price, rating: rating, imageURL: "\(self.ipAddress)product/image/\(id)", image: image, total_images: total_images, view: view, sold: sold, heavy: heavy, condition: condition, is_insurance: is_insurance, is_enabled: is_enabled, review: review)

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
        
        guard let url = URL(string: "\(ipAddress)shop/products/\(shop_id)"), let token = UserDefaults.standard.string(forKey: "Token") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            guard let data = data, error == nil else {return}
            
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
                        let rating = product.rating,
                        let image = product.image,
                        let total_images = product.total_images,
                        let view = product.view,
                        let sold = product.sold,
                        let condition = product.condition,
                        let heavy = product.heavy,
                        let is_insurance = product.is_insurance,
                        let is_enabled = product.is_enabled, let review = product.review else { break }
                    
                    print(id, name)
                    
                    let decodedProduct = ProductModel(id: id, shop_id: shop_id, name: name, description: description, stock: stock, price: price, rating: rating, imageURL: "\(self.ipAddress)product/image/\(id)", image: image, total_images: total_images, view: view, sold: sold, heavy: heavy, condition: condition, is_insurance: is_insurance, is_enabled: is_enabled, review: review)
                    
                    products.append(decodedProduct)
                }
            }
            catch{
                print("Error:", error)
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
