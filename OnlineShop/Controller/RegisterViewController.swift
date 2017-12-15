//
//  RegisterViewController.swift
//  OnlineShop
//
//  Created by Pieter Stephenson on 25/11/17.
//  Copyright © 2017 Pieter Stephenson. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class RegisterViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var txtBirth: UITextField!
    @IBOutlet weak var txtGender: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtRepeat: UITextField!
    @IBOutlet weak var txtRole: UITextField!
    
    let shopeeng = Shopeeng()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var register:Bool = false
    
    @IBAction func btnRegister(_ sender: UIBarButtonItem) {
        guard !(self.txtName.text?.isEmpty)!, !(self.txtUsername.text?.isEmpty)!, !(self.txtPassword.text?.isEmpty)!, !(self.txtRepeat.text?.isEmpty)!, !(self.txtRole.text?.isEmpty)!, !(self.txtPhoneNumber.text?.isEmpty)!, !(self.txtBirth.text?.isEmpty)!, !(self.txtGender.text?.isEmpty)! else {
            errorAlert(message: "Please fill all required fields", code: 0)
            return
        }
        
        guard let name = txtName.text, let email = txtUsername.text, let password = txtPassword.text, let confirmation = txtRepeat.text, let phone = txtPhoneNumber.text, var birth = txtBirth.text, var gender = txtGender.text, let role = txtRole.text else { return }
        
        switch gender {
        case "Male":
            gender = "M"
        case "Female":
            gender = "F"
        default:
            gender = "M"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        birth = formatter.string(from: datePickerBirth.date)

        
        let parameters = ["name": name, "email": email, "password": password, "password_confirmation": confirmation, "phone": phone, "birth": birth, "gender": gender, "role":role]
        
        let url = URL(string: "\(self.shopeeng.ipAddress)register")
        var request = URLRequest(url:url!)
        request.httpMethod = "POST"
        
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.frame = self.view.bounds
        self.activityIndicator.startAnimating()
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            
        }
        catch {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) {
            (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil
            {
                print("error=\(error!)")
                return
            }
            
            guard let data = data else {return}
            
            var message = ""
            
            do{
//                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                let json = try JSONDecoder().decode(Register.self, from: data)
//                print(json.errors?.email![0])
                
                if (json.errors == nil){
                    self.register = true
                }
                else{
                    if(json.errors?.name != nil){
                        message = (json.errors?.name![0])!
                    }
                    
                    else if(json.errors?.email != nil){
                        message = (json.errors?.email![0])!
                    }
                    
                    else if(json.errors?.password != nil){
                        message = (json.errors?.password![0])!

                    }
                    
                    else if(json.errors?.phone != nil){
                        message = (json.errors?.phone![0])!
                    }
                    
                    else if(json.errors?.birth != nil){
                        message = (json.errors?.birth![0])!
                    }
                    
                    else if(json.errors?.gender != nil){
                        message = (json.errors?.gender![0])!
                    }
                }
            }
            catch{
                print("Error deserializing json: \(error)")
            }

            OperationQueue.main.addOperation({
                //calling another function after fetching the json
                self.activityIndicator.stopAnimating()
                if(self.register){
                    self.errorAlert(message: "Registered successfully", code: 1)
                }
                else{
                    self.errorAlert(message: message, code: 0)
                }
            })
        }.resume()
    }
    
    func errorAlert(message:String, code:Int){
        let alert = UIAlertController(title: "Register", message: message, preferredStyle: .alert)
        if code == 1{
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action:UIAlertAction)->Void in
                CATransaction.setCompletionBlock({
                    self.navigationController?.popViewController(animated: true)
                    self.dismiss(animated: true, completion: nil)
                })
            }))
        }
        else{
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action:UIAlertAction)->Void in
                
            }))
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    let pickerViewRole = UIPickerView()
    let datePickerBirth = UIDatePicker()
    let pickerViewGender = UIPickerView()
    
    let pickOptionRole = ["Buyer", "Seller"]
    let pickOptionGender = ["Male", "Female"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtName.delegate = self
        txtUsername.delegate = self
        txtPassword.delegate = self
        txtRepeat.delegate = self
        txtRole.delegate = self
        txtBirth.delegate = self
        txtPhoneNumber.delegate = self
        txtGender.delegate = self
        
        pickerViewRole.delegate = self
        pickerViewGender.delegate = self
        
        txtGender.inputView = pickerViewGender
        txtGender.text = pickOptionGender[0]
        txtRole.inputView = pickerViewRole
        txtRole.text = pickOptionRole[0]
        
        txtName.text = "Cynthia"
        txtUsername.text = "ck@ckckck.wow"
        txtPhoneNumber.text = "1238772628"
        txtBirth.text = "1997-10-23"
        txtGender.text = pickOptionGender[1]
        txtPassword.text = "123456"
        txtRepeat.text = "123456"
        
        datePickerBirth.datePickerMode = .date
        datePickerBirth.addTarget(self, action: #selector(datePickerValueChanged(sender:)), for: UIControlEvents.valueChanged)
        txtBirth.inputView = datePickerBirth
    }
    
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle =  .none
        txtBirth.text = dateFormatter.string(from: sender.date)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if (self.txtRole.isFirstResponder || self.txtGender.isFirstResponder || self.txtBirth.isFirstResponder) {
            
            DispatchQueue.main.async(execute: {
                (sender as? UIMenuController)?.setMenuVisible(false, animated: false)
            })
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismissKeyboard()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == pickerViewGender{
            return pickOptionGender[row]
        }
        return pickOptionRole[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == pickerViewGender{
            return pickOptionGender.count
        }
        return pickOptionRole.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pickerViewRole{
            txtRole.text = pickOptionRole[row]
        }
        
        if(pickerView == pickerViewGender){
            txtGender.text = pickOptionGender[row]
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
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
