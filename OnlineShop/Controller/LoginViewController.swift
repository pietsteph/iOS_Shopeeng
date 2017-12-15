//
//  LoginViewController.swift
//  OnlineShop
//
//  Created by Pieter Stephenson on 23/11/17.
//  Copyright © 2017 Pieter Stephenson. All rights reserved.
//

import UIKit
import LocalAuthentication
import Alamofire

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var switchRemember: UISwitch!
    
    let shopeeng = Shopeeng()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var login:Bool = false
    
    @IBAction func btnLogin(_ sender: Any) {
        
        if(!Reachability.isConnectedToNetwork()){
            let alert = UIAlertController(title: "No Internet COnnection", message: "Make sure you are connected to a network.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action:UIAlertAction)->Void in
                
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let myUrl = URL(string: "\(shopeeng.ipAddress)login?")
        var request = URLRequest(url:myUrl!)
        request.httpMethod = "POST"
        let postString = "email=\(txtUsername.text!)&password=\(txtPassword.text!)";
        request.httpBody = postString.data(using: String.Encoding.utf8);
        
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.frame = self.view.bounds
        self.activityIndicator.startAnimating()
        
        URLSession.shared.dataTask(with: request) {
            (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil
            {
                print("error=\(error!)")
                return
            }
            
            guard let data = data else { return }
            
            do {
                let userData = try JSONDecoder().decode(Login.self, from: data)
                
                guard let id = userData.id, let role = userData.role, let token = userData.token else { return }
                
                UserDefaults.standard.set(id, forKey: "Id")
                UserDefaults.standard.set(role, forKey: "Role")
                UserDefaults.standard.set(token, forKey: "Token")
                UserDefaults.standard.set(true, forKey: "LoggedIn")
                UserDefaults.standard.set(false, forKey: "SecureApps")
                
                if UserDefaults.standard.string(forKey: "Role") == "seller"{
                    UserDefaults.standard.set(userData.shop_id, forKey: "ShopId")
                }
                
                UserDefaults.standard.synchronize()
            }
            catch {
                print("Error deserializing JSON: \(error)")
            }
            
            OperationQueue.main.addOperation({
                //calling another function after fetching the json
                self.activityIndicator.stopAnimating()
                if UserDefaults.standard.bool(forKey: "LoggedIn"){
                    if UserDefaults.standard.string(forKey: "Role") == "user"{
                        self.performSegue(withIdentifier: "login", sender: self)
                    }
                    else{
                        self.performSegue(withIdentifier: "loginSeller", sender: self)
                    }
                }
                else{
                    let alert = UIAlertController(title: "Login Failed", message: "Email and/or Password incorrect", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action:UIAlertAction)->Void in
                        
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtUsername.delegate = self
        txtPassword.delegate = self
        
        let logo = UIImage(named: "login")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        txtUsername.text = "filipus@staff.ubaya.ac.id"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if( UserDefaults.standard.bool(forKey: "SecureApps") && UserDefaults.standard.bool(forKey: "LoggedIn")){
            let context = LAContext()
            var error: NSError?
            let reason = "Identify yourself!"
            
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                    [unowned self] success, authenticationError in
                    
                    DispatchQueue.main.async {
                        if success {
                            if UserDefaults.standard.string(forKey: "Role") == "user"{
                                self.performSegue(withIdentifier: "login", sender: self)
                            }
                            else{
                                self.performSegue(withIdentifier: "loginSeller", sender: self)
                            }
                        } else {
                            let ac = UIAlertController(title: "Authentication failed", message: "Please re-enter you credential!", preferredStyle: .alert)
                            ac.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(ac, animated: true)
                        }
                    }
                }
            } else {
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) {
                    [unowned self] success, authenticationError in
                    
                    DispatchQueue.main.async {
                        if success {
                            if UserDefaults.standard.string(forKey: "Role") == "user"{
                                self.performSegue(withIdentifier: "login", sender: self)
                            }
                            else{
                                self.performSegue(withIdentifier: "loginSeller", sender: self)
                            }
                        } else {
                            let ac = UIAlertController(title: "Authentication failed", message: "Please re-enter you credential!", preferredStyle: .alert)
                            ac.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(ac, animated: true)
                        }
                    }
                }
//                let ac = UIAlertController(title: "Touch ID not available", message: "Your device is not configured for Touch ID.", preferredStyle: .alert)
//                ac.addAction(UIAlertAction(title: "OK", style: .default))
//                present(ac, animated: true)
            }
        }
        else if UserDefaults.standard.bool(forKey: "LoggedIn") {
            if UserDefaults.standard.string(forKey: "Role") == "user"{
                self.performSegue(withIdentifier: "login", sender: self)
            }
            else{
                self.performSegue(withIdentifier: "loginSeller", sender: self)
            }
        }
    }
    
    
    @IBAction func switchChange(_ sender: UISwitch) {
        if sender.isOn{
            UserDefaults.standard.set(true, forKey: "RememberUsername")
        }
        else{
            UserDefaults.standard.set(false, forKey: "RememberUsername")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == self.txtUsername){
            self.txtPassword.becomeFirstResponder()
        }
        else if(textField == self.txtPassword){
            resignFirstResponder()
            btnLogin(self)
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "login"{
            
        }
        
    }

}
