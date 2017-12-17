//
//  ShopRegisterTableViewController.swift
//  OnlineShop
//
//  Created by Pieter Stephenson on 17/12/17.
//  Copyright © 2017 Pieter Stephenson. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class ShopRegisterTableViewController: UITableViewController, UITextFieldDelegate, NVActivityIndicatorViewable {

    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtDescription: UITextView!
    
    let shopeeng = Shopeeng()
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var user_id = Int()
    
    @IBAction func btnSubmit(_ sender: Any) {
        register()
    }
    
    func register() {
        guard !(self.txtName.text?.isEmpty)!, !(self.txtPhone.text?.isEmpty)!, !(self.txtDescription.text?.isEmpty)! else {
            showAlert(title: "Alert", message: "Please fill all required fields", code: 0)
            return
        }
        
        guard let name = txtName.text, let phone = txtPhone.text, let description = txtDescription.text else { return }
        
        let parameters = ["name": name, "phone": phone, "description": description, "user_id": user_id] as [String : Any]
        
        guard let url = URL(string: "\(self.shopeeng.ipAddress)shop"), let token = UserDefaults.standard.string(forKey: "Token") else { return }
        
        var request = URLRequest(url:url)
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
            
            var id = 0
            
            do{
                let json = try JSONDecoder().decode(Shop.self, from: data)
                print(json)
                if (json.id != nil){
                    id = json.id!
                }
                else{
                    return
                }
            }
            catch{
                print("Error deserializing json: \(error)")
            }
            
            OperationQueue.main.addOperation({
                //calling another function after fetching the json
//                self.stopAnimating()
                if(id == 0){
                    self.showAlert(title: "Register Failed", message: "Failed to register. Please try again later.", code: 0)
                }
                else{
                    UserDefaults.standard.set(id, forKey: "ShopId")
                    self.showAlert(title: "Register Success", message: "You are registered successfully", code: 1)
                }
            })
        }.resume()
    }
    
    func showAlert(title:String, message:String, code:Int){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if code == 1{
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action:UIAlertAction)->Void in
                CATransaction.setCompletionBlock({
                    self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                })
            }))
        }
        else{
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action:UIAlertAction)->Void in
                
            }))
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtName.delegate = self
        txtPhone.delegate = self
        
        self.tableView.keyboardDismissMode = .interactive

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
