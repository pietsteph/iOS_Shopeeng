//
//  ProfileShopViewController.swift
//  OnlineShop
//
//  Created by Pieter Stephenson on 29/11/17.
//  Copyright © 2017 Pieter Stephenson. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class ProfileShopViewController: UIViewController, UITextFieldDelegate, NVActivityIndicatorViewable, UITextViewDelegate {
    
    let shopeeng = Shopeeng()

    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtDescription: UITextView!
    
    @IBAction func btnSave(_ sender: UIBarButtonItem) {
        updateProfile()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        }
        
        txtName.delegate = self
        txtPhone.delegate = self
        txtDescription.delegate = self
        txtDescription.sizeToFit()
        txtDescription.isEditable = true
        
        fetchProfile()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchProfile(){
        let shop_id = UserDefaults.standard.integer(forKey: "ShopId")

        guard let token = UserDefaults.standard.string(forKey: "Token"), let url = URL(string: "\(self.shopeeng.ipAddress)shop/\(shop_id)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let size = CGSize(width: 40, height: 40)
        self.startAnimating(size, message: "Please Wait", messageFont: UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.regular), type: NVActivityIndicatorType.ballPulse, color: self.delegate.themeColor, padding: NVActivityIndicatorView.DEFAULT_PADDING, displayTimeThreshold: NVActivityIndicatorView.DEFAULT_BLOCKER_DISPLAY_TIME_THRESHOLD, minimumDisplayTime: NVActivityIndicatorView.DEFAULT_BLOCKER_MINIMUM_DISPLAY_TIME, backgroundColor: NVActivityIndicatorView.DEFAULT_BLOCKER_BACKGROUND_COLOR, textColor: NVActivityIndicatorView.DEFAULT_TEXT_COLOR)
        
        URLSession.shared.dataTask(with: request) {
            (data: Data?, response: URLResponse?, error: Error?) in
            
            var name = String()
            var phone = String()
            var description = String()
            
            if error != nil
            {
                print("error=\(error!)")
                return
            }
            
            guard let data = data else{
                return
            }
            
            do {
                let shop = try JSONDecoder().decode(Shop.self, from: data)
                print(shop)
                guard shop.name != nil, shop.description != nil, shop.phone != nil else { return }
                
                name = shop.name!
                phone = shop.phone!
                description = shop.description!
            }
            catch {
                print("Error deserializing JSON fetch profile: \(error)")
            }
            
            OperationQueue.main.addOperation({
                //calling another function after fetching the json
                self.txtName.text = name
                self.txtPhone.text = phone
                self.txtDescription.text = description
                self.txtDescription.sizeToFit()
                
                self.stopAnimating()
            })
        }.resume()
    }
    
    func updateProfile(){
        guard !((txtName.text)?.isEmpty)! else{
            let alert = UIAlertController(title: "Alert", message: "Name field cannot be empty", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction)->Void in
                
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        guard let name = txtName.text, let phone = txtPhone.text, let description = txtDescription.text else { return }

        let shop_id = UserDefaults.standard.integer(forKey: "ShopId")
        guard let token = UserDefaults.standard.string(forKey: "Token") else { return }
        
        guard let url = URL(string: "\(self.shopeeng.ipAddress)shop/\(shop_id)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        let parameters = ["name": name, "phone": phone, "description": description]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        }
        catch {
            print(error.localizedDescription)
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let size = CGSize(width: 40, height: 40)
        self.startAnimating(size, message: "Please Wait", messageFont: UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.regular), type: NVActivityIndicatorType.ballPulse, color: self.delegate.themeColor, padding: NVActivityIndicatorView.DEFAULT_PADDING, displayTimeThreshold: NVActivityIndicatorView.DEFAULT_BLOCKER_DISPLAY_TIME_THRESHOLD, minimumDisplayTime: NVActivityIndicatorView.DEFAULT_BLOCKER_MINIMUM_DISPLAY_TIME, backgroundColor: NVActivityIndicatorView.DEFAULT_BLOCKER_BACKGROUND_COLOR, textColor: NVActivityIndicatorView.DEFAULT_TEXT_COLOR)
        
        URLSession.shared.dataTask(with: request) {
            (data: Data?, response: URLResponse?, error: Error?) in
            
            guard let data = data, error == nil else { return }
            
            var message = ""
            
            do {
                let json = try JSONDecoder().decode(User.self, from: data)
                
                if (json.errors == nil){
                    
                }
                else{
                    if(json.errors?.name != nil){
                        message = (json.errors?.name![0])!
                    }
                }
            }
            catch {
                print("Error deserializing JSON: \(error)")
            }
            
            OperationQueue.main.addOperation({
                //calling another function after fetching the json
                self.stopAnimating()
                if message == ""{
                    self.showAlert(title: "Profile Update", message: "Your profile has been updated")
                    self.fetchProfile()
                }
                else{
                    self.showAlert(title: "Profile Update Failed", message: message)
                }
            })
        }.resume()
    }
    
    func showAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction)->Void in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
