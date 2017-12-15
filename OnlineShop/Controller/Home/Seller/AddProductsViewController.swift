//
//  AddProductsViewController.swift
//  OnlineShop
//
//  Created by Pieter Stephenson on 30/11/17.
//  Copyright © 2017 Pieter Stephenson. All rights reserved.
//

import UIKit

class AddProductsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UIScrollViewDelegate {

    @IBOutlet weak var btnImage: UIButton!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var txtStock: UITextField!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var txtPrice: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    let shopeeng = Shopeeng()
    var image:UIImage? = nil
    var stock:Int = 0
    var price:Int = 0
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    @IBAction func btnCancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showAlert(alert:String){
        let alert = UIAlertController(title: "Alert", message: alert, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction)->Void in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnSave(_ sender: UIBarButtonItem) {
        guard txtName.text != nil, txtDescription.text != "Description", txtStock.text != nil, txtPrice.text != nil else{
            showAlert(alert: "Please fill all required fields")
            return
        }
        
        guard txtStock.text != "0" else{
            showAlert(alert: "Stock must be greater than 0")
            return
        }
        
        guard txtPrice.text != "0" else{
            showAlert(alert: "Price must be grater than 0")
            return
        }
        
        let myUrl = URL(string: self.shopeeng.URL_ADD_PRODUCT)
        var request = URLRequest(url:myUrl!)
        request.httpMethod = "POST"
        let postString = "name=\(txtName.text!)&shop_id=\(UserDefaults.standard.integer(forKey: "ShopId"))&description=\(txtDescription.text!)&stock=\(stock)&price=\(price)";
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

            guard let data = data else {return}

            var product_id = Int()

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                if let result = json!["result"] as? Int {
                    product_id = result
                }
            }
            catch {
                print("Error deserializing JSON: \(error)")
            }

            OperationQueue.main.addOperation({
                self.uploadImage(product_id: product_id)
            })
            }.resume()
        
    }
    
    func uploadImage(product_id:Int){
        let url = URL(string: shopeeng.URL_ADD_PRODUCT_IMAGE)
        var request = URLRequest(url:url!);
        request.httpMethod = "POST";
        
        let param = [
            "product_id": "\(product_id)"
        ]
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        guard image != nil else {
            let alert = UIAlertController(title: "Alert", message: "Please insert image to upload", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction)->Void in
                
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let imageData = UIImageJPEGRepresentation(image!, 1)
        
        request.httpBody = createBodyWithParameters(parameters: param as [String : String], filePathKey: "file", imageDataKey: imageData! as NSData, boundary: boundary) as Data
        
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
                self.activityIndicator.stopAnimating()
                let alert = UIAlertController(title: "Alert", message: uploadMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction)->Void in
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadMyProduct"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
        task.resume()
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
        let deleteAction = UIAlertAction(title: "Delete Profile Picture", style: .destructive) { (alert : UIAlertAction!) in
            self.image = nil
            self.btnImage.setBackgroundImage(self.image, for: .normal)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert : UIAlertAction!) in
        }
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(cancelAction)
        optionMenu.addAction(deleteAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        image = info[UIImagePickerControllerEditedImage] as? UIImage
        btnImage.setBackgroundImage(image, for: .normal)
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
        stepper.minimumValue = 0
        stepper.autorepeat = true
        
        txtName.delegate = self
        txtDescription.delegate = self
        txtPrice.delegate = self
        txtStock.delegate = self
        
        txtStock.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        txtPrice.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField == txtStock{
            if (textField.text?.isEmpty)!{
                stock = 0
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
        
        if (textField.text?.contains("0"))!{
            let realValue = Int(textField.text!)!
            textField.text = "\(realValue)"
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == "Description"{
            textView.text = nil
        }
        
        if textView.text == nil{
            textView.text = "Description"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        let filename = "image.jpg"
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        self.contentView.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField.tag {
        case 2...3:
            scrollView.setContentOffset(CGPoint(x:0, y:100), animated: true)
        default:
            print("Do nothing")
        }
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if(self.txtStock.isFirstResponder || self.txtPrice.isFirstResponder){
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
