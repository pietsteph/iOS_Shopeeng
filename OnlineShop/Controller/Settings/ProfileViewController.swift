//
//  ProfileViewController.swift
//  OnlineShop
//
//  Created by Pieter Stephenson on 26/11/17.
//  Copyright © 2017 Pieter Stephenson. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Alamofire

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, NVActivityIndicatorViewable, UIPickerViewDelegate, UIPickerViewDataSource {
    let shopeeng = Shopeeng()
    var image = UIImage()
    let activityIndicator:NVActivityIndicatorView? = nil
    
    @IBOutlet weak var btnProfilePic: UIButton!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtBirth: UITextField!
    @IBOutlet weak var txtGender: UITextField!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    
    @IBAction func selectPhoto(_ sender: Any) {
        let camera = DSCameraHandler(delegate_: self)
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        optionMenu.popoverPresentationController?.sourceView = self.view
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { (alert : UIAlertAction!) in
            camera.getCameraOn(self, canEdit: true)
        }
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .default) { (alert : UIAlertAction!) in
            camera.getPhotoLibraryOn(self, canEdit: true)
        }
        let deleteAction = UIAlertAction(title: "Delete Profile Picture", style: .destructive) { (alert : UIAlertAction!) in
            self.deleteProfilePicture()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert : UIAlertAction!) in
        }
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(cancelAction)
        optionMenu.addAction(deleteAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    @IBAction func btnSave(_ sender: UIBarButtonItem) {
        updateProfile()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        image = info[UIImagePickerControllerEditedImage] as! UIImage
        self.dismiss(animated: true, completion: nil)
        uploadProfilePicture()
    }
    
    func deleteProfilePicture(){
        
        let id = UserDefaults.standard.integer(forKey: "Id")
        guard let token = UserDefaults.standard.string(forKey: "Token") else { return }
        
        guard let url = URL(string: "\(shopeeng.ipAddress)user/\(id)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let size = CGSize(width: 40, height: 40)
        self.startAnimating(size, message: "Please Wait", messageFont: UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.regular), type: NVActivityIndicatorType.ballPulse, color: self.delegate.themeColor, padding: NVActivityIndicatorView.DEFAULT_PADDING, displayTimeThreshold: NVActivityIndicatorView.DEFAULT_BLOCKER_DISPLAY_TIME_THRESHOLD, minimumDisplayTime: NVActivityIndicatorView.DEFAULT_BLOCKER_MINIMUM_DISPLAY_TIME, backgroundColor: NVActivityIndicatorView.DEFAULT_BLOCKER_BACKGROUND_COLOR, textColor: NVActivityIndicatorView.DEFAULT_TEXT_COLOR)
        
        URLSession.shared.dataTask(with: request) {
            (data: Data?, response: URLResponse?, error: Error?) in
            
            var deleteMessage = String()
            
            if error != nil
            {
                print("error=\(error!)")
                return
            }
            
            guard let data = data else {return}
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                deleteMessage = json!["Message"]! as! String
            }
            catch {
                print("Error deserializing JSON: \(error)")
            }
            
            OperationQueue.main.addOperation({
                //calling another function after fetching the json
                self.stopAnimating()
                self.fetchImage()
                let alert = UIAlertController(title: "Profile Picture", message: deleteMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction)->Void in
                    
                }))
                self.present(alert, animated: true, completion: nil)
            })
            }.resume()
    }
    
    func uploadProfilePicture(){
        guard let imageData = UIImageJPEGRepresentation(image, 1), let id = UserDefaults.standard.string(forKey: "Id"), let token = UserDefaults.standard.string(forKey: "Token") else { return }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Accept": "application/json"
        ]
        
        let frame = CGRect(x: self.btnProfilePic.center.x-20, y: self.btnProfilePic.center.y-20, width: 20, height: 20)
        let loader = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.ballPulseSync, color: delegate.themeColor, padding: NVActivityIndicatorView.DEFAULT_PADDING)
        self.btnProfilePic.addSubview(loader)
        loader.startAnimating()
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(imageData, withName: "image_user", fileName: "\(id)", mimeType: "image/jpg")
        }, to: "\(shopeeng.ipAddress)user", headers: headers,
           encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    loader.stopAnimating()
                    
                    let alert = UIAlertController(title: "Profile Picture", message: "Profile image updated", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction)->Void in
                        
                    }))
                    self.present(alert, animated: true, completion: nil)
                    
                    self.fetchImage()
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        })
    }
    
    func fetchImage(){
        guard let id = UserDefaults.standard.string(forKey: "Id"), let token = UserDefaults.standard.string(forKey: "Token") else { return }
        guard let url = URL(string: "\(shopeeng.ipAddress)user/image/\(id)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let frame = CGRect(x: self.btnProfilePic.center.x-20, y: self.btnProfilePic.center.y-20, width: 20, height: 20)
        let loader = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.ballPulseSync, color: delegate.themeColor, padding: NVActivityIndicatorView.DEFAULT_PADDING)
        self.btnProfilePic.addSubview(loader)
        loader.startAnimating()
        
        URLSession.shared.dataTask( with: request, completionHandler: {
            (data, response, error) -> Void in

            guard let data = data, error == nil else {
                return
            }

            DispatchQueue.main.async {
                self.btnProfilePic.setBackgroundImage(UIImage(data: data), for: .normal)
                loader.stopAnimating()
            }
        }).resume()
    }
    
    func fetchProfile(){
        let user_id = UserDefaults.standard.integer(forKey: "Id")
        guard let token = UserDefaults.standard.string(forKey: "Token") else { return }
        
        let myUrl = URL(string: "\(self.shopeeng.ipAddress)user/\(user_id)")
        var request = URLRequest(url:myUrl!)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let size = CGSize(width: 40, height: 40)
        self.startAnimating(size, message: "Please Wait", messageFont: UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.regular), type: NVActivityIndicatorType.ballPulse, color: self.delegate.themeColor, padding: NVActivityIndicatorView.DEFAULT_PADDING, displayTimeThreshold: NVActivityIndicatorView.DEFAULT_BLOCKER_DISPLAY_TIME_THRESHOLD, minimumDisplayTime: NVActivityIndicatorView.DEFAULT_BLOCKER_MINIMUM_DISPLAY_TIME, backgroundColor: NVActivityIndicatorView.DEFAULT_BLOCKER_BACKGROUND_COLOR, textColor: NVActivityIndicatorView.DEFAULT_TEXT_COLOR)
        
        URLSession.shared.dataTask(with: request) {
            (data: Data?, response: URLResponse?, error: Error?) in
            
            var name = String()
            var email = String()
            var phone = String()
            var birth = String()
            var gender = String()
            
            if error != nil
            {
                print("error=\(error!)")
                return
            }
            
            guard let data = data else{
                return
            }
            
            var date = Date()
            
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
//                print(user)
                guard user.name != nil, user.email != nil, user.phone != nil else { return }
                
                name = user.name!
                email = user.email!
                phone = user.phone!
                
                guard let strDate = user.birth else { return }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "YYYY-MM-dd"
                date = dateFormatter.date(from: strDate)!
                dateFormatter.dateFormat = "MMM d, yyyy"
                dateFormatter.dateStyle = .long
                birth = "\(dateFormatter.string(from: date))"
                
                switch user.gender! {
                case "M":
                    gender = "Male"
                case "F":
                    gender = "Female"
                default:
                    gender = "Male"
                }
            }
            catch {
                print("Error deserializing JSON fetch profile: \(error)")
            }
            
            OperationQueue.main.addOperation({
                //calling another function after fetching the json
                self.txtName.text = name
                self.txtUsername.text = email
                self.datePickerBirth.date = date
                self.txtBirth.text = birth
                self.txtPhoneNumber.text = phone
                self.txtGender.text = gender
                
                self.stopAnimating()
            })
        }.resume()
    }
    
    func updateProfile(){
        guard !((txtName.text)?.isEmpty)!, !((txtUsername.text)?.isEmpty)!, !((txtBirth.text)?.isEmpty)!, !((txtGender.text)?.isEmpty)!, !((txtPhoneNumber.text)?.isEmpty)! else{
            let alert = UIAlertController(title: "Alert", message: "Please fill all required fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction)->Void in
                
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        guard let name = txtName.text, let email = txtUsername.text, let phone = txtPhoneNumber.text, var birth = txtBirth.text, var gender = txtGender.text else { return }
        
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
        
        let id = UserDefaults.standard.integer(forKey: "Id")
        guard let token = UserDefaults.standard.string(forKey: "Token") else {return}
        
        guard let url = URL(string: "\(self.shopeeng.ipAddress)user/\(id)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        let parameters = ["name": name, "email": email, "phone": phone, "birth": birth, "gender": gender]
        
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
            
            if error != nil
            {
                print("error=\(error!)")
                return
            }
            
            guard let data = data else { return }
            
            var message = ""
            
            do {
                let json = try JSONDecoder().decode(Register.self, from: data)

                if (json.errors == nil){
                    
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
    let datePickerBirth = UIDatePicker()
    let pickerViewGender = UIPickerView()
    let pickOptionGender = ["Male", "Female"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        }
        
        btnProfilePic.layer.borderWidth = 2.0
        btnProfilePic.layer.borderColor = delegate.themeColor.cgColor
        btnProfilePic.layer.cornerRadius = 90
        btnProfilePic.clipsToBounds = true
        
        txtName.delegate = self
        txtUsername.delegate = self
        txtBirth.delegate = self
        txtPhoneNumber.delegate = self
        txtGender.delegate = self
        
        pickerViewGender.delegate = self
        
        txtGender.inputView = pickerViewGender
        
        datePickerBirth.datePickerMode = .date
        datePickerBirth.addTarget(self, action: #selector(datePickerValueChanged(sender:)), for: UIControlEvents.valueChanged)
        txtBirth.inputView = datePickerBirth
        
        fetchImage()
        fetchProfile()
    }
    
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle =  .none
        txtBirth.text = dateFormatter.string(from: sender.date)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.becomeFirstResponder()
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if (self.txtGender.isFirstResponder || self.txtBirth.isFirstResponder) {
            
            DispatchQueue.main.async(execute: {
                (sender as? UIMenuController)?.setMenuVisible(false, animated: false)
            })
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickOptionGender[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickOptionGender.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        txtGender.text = pickOptionGender[row]
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
