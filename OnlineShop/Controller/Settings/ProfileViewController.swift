//
//  ProfileViewController.swift
//  OnlineShop
//
//  Created by Pieter Stephenson on 26/11/17.
//  Copyright © 2017 Pieter Stephenson. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    let shopeeng = Shopeeng()
    var image = UIImage()
    
    @IBOutlet weak var btnProfilePic: UIButton!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtUsername: UITextField!
    
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
        let myUrl = URL(string: shopeeng.URL_DELETE_PROFILE_PICTURE)
        var request = URLRequest(url:myUrl!)
        request.httpMethod = "POST"
        let postString = "id=\(UserDefaults.standard.string(forKey: "Id")!)&token=\(UserDefaults.standard.string(forKey: "Token")!)";
        request.httpBody = postString.data(using: String.Encoding.utf8);
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.btnProfilePic.addSubview(activityIndicator)
        activityIndicator.frame = self.btnProfilePic.bounds
        activityIndicator.startAnimating()
        
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
                activityIndicator.stopAnimating()
                self.fetchImage()
                let alert = UIAlertController(title: "Alert", message: deleteMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction)->Void in
                    
                }))
                self.present(alert, animated: true, completion: nil)
            })
            }.resume()
    }
    
    func uploadProfilePicture(){
        let url = URL(string: shopeeng.URL_UPDATE_PROFILE_PICTURE)
        var request = URLRequest(url:url!);
        request.httpMethod = "POST";
        
        let param = ["user_id" : UserDefaults.standard.string(forKey: "Id")]
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let imageData = UIImageJPEGRepresentation(image, 1)
        
        guard imageData != nil else {return}
        
        request.httpBody = createBodyWithParameters(parameters: param as? [String : String], filePathKey: "file", imageDataKey: imageData! as NSData, boundary: boundary) as Data
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        btnProfilePic.addSubview(activityIndicator)
        activityIndicator.frame = btnProfilePic.bounds
        activityIndicator.startAnimating()
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            if error != nil {
                print("error=\(String(describing: error))")
                return
            }
            
            guard let data = data else {return}
            
            var uploadMessage = String()
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                uploadMessage = json!["Message"]! as! String
            }
            catch {
                print(error)
            }
            
            OperationQueue.main.addOperation {
                activityIndicator.stopAnimating()
                self.fetchImage()
                let alert = UIAlertController(title: "Alert", message: uploadMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction)->Void in

                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
        task.resume()
    }
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        let body = NSMutableData()
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: String.Encoding.utf8)!)
                body.append("\(value)\r\n".data(using: String.Encoding.utf8)!)
            }
        }
        
        let filename = UserDefaults.standard.string(forKey: "Id")!+".jpg"
        let mimetype = "image/jpg"
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(imageDataKey as Data)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        
        return body
    }
    
    func generateBoundaryString() -> String
    {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    func fetchImage(){
        let url = shopeeng.URL_PROFILE_PICTURE + UserDefaults.standard.string(forKey: "Id")! + ".jpg"
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.view.addSubview(activityIndicator)
        activityIndicator.frame = self.view.bounds
        activityIndicator.startAnimating()
        
        if let profileURL = URL(string: url) {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let urlContent = try? Data(contentsOf: profileURL)
                if let imageData = urlContent{
                    DispatchQueue.main.async {
                        self?.btnProfilePic.setBackgroundImage(UIImage(data: imageData), for: .normal)
                        activityIndicator.stopAnimating()
                    }
                }
                else{
                    DispatchQueue.main.async(execute: {
                        self?.btnProfilePic.setBackgroundImage(UIImage(named: "profile"), for: .normal)
                        activityIndicator.stopAnimating()
                    })
                    
                }
            }
        }
    }
    
    func fetchProfile(){
        let myUrl = URL(string: self.shopeeng.URL_PROFILE)
        var request = URLRequest(url:myUrl!)
        request.httpMethod = "POST"
        let postString = "id=\(UserDefaults.standard.string(forKey: "Id")!)";
        request.httpBody = postString.data(using: String.Encoding.utf8);
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.view.addSubview(activityIndicator)
        activityIndicator.frame = self.view.bounds
        activityIndicator.startAnimating()
        
        URLSession.shared.dataTask(with: request) {
            (data: Data?, response: URLResponse?, error: Error?) in
            
            var username = String()
            var name = String()
            
            if error != nil
            {
                print("error=\(error!)")
                return
            }
            
            guard let data = data else{
                return
            }
            
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                username = user.username!
                name = user.name!
            }
            catch {
                print("Error deserializing JSON: \(error)")
            }
            
            OperationQueue.main.addOperation({
                //calling another function after fetching the json
                self.txtName.text = name
                self.txtUsername.text = username
                activityIndicator.stopAnimating()
            })
            }.resume()
    }
    
    func updateProfile(){
        guard !((txtName.text)?.isEmpty)!, !((txtUsername.text)?.isEmpty)! else{
            let alert = UIAlertController(title: "Alert", message: "Please fill all required fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction)->Void in
                
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let myUrl = URL(string: self.shopeeng.URL_UPDATE_PROFILE)
        var request = URLRequest(url:myUrl!)
        request.httpMethod = "POST"
        let postString = "id=\(UserDefaults.standard.string(forKey: "Id")!)&token=\(UserDefaults.standard.string(forKey: "Token")!)&name=\(txtName.text!)&username=\(txtUsername.text!)";
        request.httpBody = postString.data(using: String.Encoding.utf8);
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.view.addSubview(activityIndicator)
        activityIndicator.frame = self.view.bounds
        activityIndicator.startAnimating()
        
        URLSession.shared.dataTask(with: request) {
            (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil
            {
                print("error=\(error!)")
                return
            }
            
            var message = String()
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                message = json!["Message"]! as! String
            }
            catch {
                print("Error deserializing JSON: \(error)")
            }
            
            OperationQueue.main.addOperation({
                //calling another function after fetching the json
                activityIndicator.stopAnimating()
                let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction)->Void in

                }))
                self.present(alert, animated: true, completion: nil)
            })
        }.resume()
    }
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
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
        
        fetchImage()
        fetchProfile()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
