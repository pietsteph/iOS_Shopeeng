//
//  AddProductsViewController.swift
//  OnlineShop
//
//  Created by Pieter Stephenson on 30/11/17.
//  Copyright © 2017 Pieter Stephenson. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Alamofire

class AddProductsViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, NVActivityIndicatorViewable{

    @IBOutlet weak var btnImage: UIButton!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var txtStock: UITextField!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var txtPrice: UITextField!
    @IBOutlet weak var switchCondition: UISwitch!
    @IBOutlet weak var txtWeight: UITextField!
    @IBOutlet weak var switchInsurance: UISwitch!
    
    let shopeeng = Shopeeng()
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var image = UIImage()
    var stock:Int = 1
    var price:Int = 0
    var weight:Double = 0
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    @IBAction func btnCancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showAlert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction)->Void in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnSave(_ sender: UIBarButtonItem) {
        guard !(txtName.text?.isEmpty)!, !(txtDescription.text.isEmpty) else{
            showAlert(title: "Add Product Failed", message: "Please fill all required fields")
            return
        }

        guard price > 0 else{
            showAlert(title: "Add Product Failed",message: "Price cannot be 0")
            return
        }

        guard weight > 0.0 else{
            showAlert(title: "Add Product Failed",message: "Weight must be greater than 0")
            return
        }
        
        guard let name = txtName.text, let description = txtDescription.text else{
            return
        }
        
        let condition = switchCondition.isOn ? "new" : "old"
        let insurance = switchInsurance.isOn ? 1 : 0
        
        let shop_id = UserDefaults.standard.integer(forKey: "ShopId")
        let parameters = ["name": name, "description": description, "heavy": weight, "stock": stock, "price": price, "condition": condition, "total_images": 1, "shop_id": shop_id, "is_insurance": insurance] as [String : Any]
        
        guard let url = URL(string: "\(self.shopeeng.ipAddress)product"), let token = UserDefaults.standard.string(forKey: "Token") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        }
        catch {
            print(error.localizedDescription)
        }
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
//        let size = CGSize(width: 40, height: 40)
//        startAnimating(size, message: "Please Wait", messageFont: UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.regular), type: NVActivityIndicatorType.ballPulse, color: delegate.themeColor, padding: NVActivityIndicatorView.DEFAULT_PADDING, displayTimeThreshold: NVActivityIndicatorView.DEFAULT_BLOCKER_DISPLAY_TIME_THRESHOLD, minimumDisplayTime: NVActivityIndicatorView.DEFAULT_BLOCKER_MINIMUM_DISPLAY_TIME, backgroundColor: NVActivityIndicatorView.DEFAULT_BLOCKER_BACKGROUND_COLOR, textColor: NVActivityIndicatorView.DEFAULT_TEXT_COLOR)
        
        URLSession.shared.dataTask(with: request) {
            (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil
            {
                print("error=\(error!)")
                return
            }
            
            guard let data = data else {return}
            
            var product_id = 0
            
            do{
                let json = try JSONDecoder().decode(Product.self, from: data)
                print(json)
                guard let id = json.id else { return }
                product_id = id
            }
            catch{
                print("Error deserializing json: \(error)")
            }
            
            OperationQueue.main.addOperation({
                if product_id != 0{
                    self.uploadImage(product_id: product_id)
                }
                else{
                    self.stopAnimating()
                    let alert = UIAlertController(title: "Add Product Failed", message: "An error has occured. Please try again later.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action:UIAlertAction)->Void in

                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }.resume()
    }
    
    func uploadImage(product_id:Int){
        print("woi")
        guard let imageData = UIImageJPEGRepresentation(image, 1), let token = UserDefaults.standard.string(forKey: "Token") else { return }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Accept": "application/json"
        ]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(imageData, withName: "image_product", fileName: "\(product_id)", mimeType: "image/jpg")
        }, to: "\(shopeeng.ipAddress)product/image/", headers: headers,
           encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    debugPrint(response)
                    let alert = UIAlertController(title: "Add Product", message: "Your new product has been added successfully", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action:UIAlertAction)->Void in
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "loadMyProduct"), object: nil)
                        self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        })
    }
    
    @IBAction func addPicture(_ sender: UIButton) {
        let camera = DSCameraHandler(delegate_: self)
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        optionMenu.popoverPresentationController?.sourceView = self.view
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { (alert : UIAlertAction!) in
            camera.getCameraOn(self, canEdit: true)
        }
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .default) { (alert : UIAlertAction!) in
            camera.getPhotoLibraryOn(self, canEdit: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert : UIAlertAction!) in
        }
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        image = info[UIImagePickerControllerEditedImage] as! UIImage
        btnImage.contentMode = .scaleAspectFit
        btnImage.setImage(image, for: .normal)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func stepperAction(_ sender: UIStepper) {
        stock = Int(stepper.value)
        txtStock.text = "\(stock)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stock = Int(stepper.value)
        txtStock.text = "\(stock)"
        txtPrice.text = "\(price)"
        txtWeight.text = "\(weight)"
        stepper.minimumValue = 0
        stepper.autorepeat = true
        
        txtName.delegate = self
        txtPrice.delegate = self
        txtStock.delegate = self
        txtWeight.delegate = self
        
        txtStock.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        txtPrice.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        txtWeight.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        txtName.text = "Tanaman Hijau"
        txtDescription.text = "Tanaman ini cocok untuk menghiasi halaman rumah Anda."
        price = 500000
        stock = 2
        weight = 54.25
        switchCondition.isOn = true
        switchInsurance.isOn = false
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField == txtStock{
            if (textField.text?.isEmpty)!{
                stock = 1
                textField.text = "\(stock)"
            }
            else{
                stock = Int(txtStock.text!)!
            }
            print(stock)
        }
        
        if textField == txtPrice{
            if !(textField.text?.isEmpty)!{
                price = Int(txtPrice.text!)!
            }
            else{
                price = 0
                txtPrice.text = "\(price)"
            }
        }
        
        if textField == txtWeight{
            if !(textField.text?.isEmpty)!{
                weight = Double(txtWeight.text!)!
            }
            else{
                weight = 0.0
                txtWeight.text = "\(weight)"
            }
        }
        
        if( textField == txtStock || textField == txtPrice){
            if (textField.text?.contains("0"))!{
                let realValue = Int(textField.text!)!
                textField.text = "\(realValue)"
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        self.tableView.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if(self.txtStock.isFirstResponder || self.txtPrice.isFirstResponder || self.txtWeight.isFirstResponder){
            DispatchQueue.main.async(execute: {
                (sender as? UIMenuController)?.setMenuVisible(false, animated: false)
            })
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
