//
//  SettingsTableViewController.swift
//  OnlineShop
//
//  Created by Pieter Stephenson on 25/11/17.
//  Copyright © 2017 Pieter Stephenson. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class SettingsTableViewController: UITableViewController, NVActivityIndicatorViewable {
    let setting_name_list_user:[String] = ["Profile", "Change Password", "Change Address", "Secure Apps", "Logout"]
    let setting_icon_list_user:[String] = ["profile", "lock", "location", "fingerprint", "logout"]
    
    let setting_name_list_seller:[String] = ["Profile", "Shop Profile", "Change Password", "Change Address", "Secure Apps", "Logout"]
    let setting_icon_list_seller:[String] = ["profile", "store", "lock", "location", "fingerprint", "logout"]
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    let shopeeng = Shopeeng()
    let activityIndicator:NVActivityIndicatorView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
        tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (UserDefaults.standard.string(forKey: "Role") == "buyer") {
            return setting_name_list_user.count
        }
        else{
            return setting_name_list_seller.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath)
        
        if (UserDefaults.standard.string(forKey: "Role") == "user") {
            if let myCell = cell as? SettingsTableViewCell{
                
                let bgColorView = UIView()
                bgColorView.backgroundColor = delegate.themeColor
                myCell.selectedBackgroundView = bgColorView
                myCell.settingIcon?.image = UIImage(named: setting_icon_list_user[indexPath.row])
                myCell.settingName?.text = setting_name_list_user[indexPath.row]
                if (setting_name_list_user[indexPath.row] == "Profile" || setting_name_list_user[indexPath.row] == "Change Password" ||
                    setting_name_list_user[indexPath.row] == "Change Address") {
                    myCell.accessoryType = .disclosureIndicator
                }
                
                if(setting_name_list_user[indexPath.row] == "Secure Apps"){
                    let cell = tableView.dequeueReusableCell(withIdentifier: "FingerprintCell", for: indexPath)
                    if let myCell = cell as? SettingsTableViewCell{
                        let bgColorView = UIView()
                        bgColorView.backgroundColor = nil
                        myCell.selectedBackgroundView = bgColorView
                        myCell.settingIcon?.image = UIImage(named: setting_icon_list_user[indexPath.row])
                        myCell.settingName?.text = setting_name_list_user[indexPath.row]
                        
                        if(UserDefaults.standard.bool(forKey: "SecureApps")){
                            myCell.settingSwitch.setOn(true, animated: false)
                        }
                        else{
                            myCell.settingSwitch.setOn(false, animated: false)
                        }
                    }
                    return cell
                }
            }
        }
        else {
            if let myCell = cell as? SettingsTableViewCell{
                let bgColorView = UIView()
                bgColorView.backgroundColor = delegate.themeColor
                myCell.selectedBackgroundView = bgColorView
                myCell.settingIcon?.image = UIImage(named: setting_icon_list_seller[indexPath.row])
                myCell.settingName?.text = setting_name_list_seller[indexPath.row]
                if (setting_name_list_seller[indexPath.row] == "Profile" || setting_name_list_seller[indexPath.row] == "Shop Profile" ||
                    setting_name_list_seller[indexPath.row] == "Change Password" ||
                    setting_name_list_seller[indexPath.row] == "Change Address") {
                    myCell.accessoryType = .disclosureIndicator
                }
                
                if(setting_name_list_seller[indexPath.row] == "Secure Apps"){
                    let cell = tableView.dequeueReusableCell(withIdentifier: "FingerprintCell", for: indexPath)
                    if let myCell = cell as? SettingsTableViewCell{
                        let bgColorView = UIView()
                        bgColorView.backgroundColor = nil
                        myCell.selectedBackgroundView = bgColorView
                        myCell.settingIcon?.image = UIImage(named: setting_icon_list_seller[indexPath.row])
                        myCell.settingName?.text = setting_name_list_seller[indexPath.row]
                        
                        if(UserDefaults.standard.bool(forKey: "SecureApps")){
                            myCell.settingSwitch.setOn(true, animated: false)
                        }
                        else{
                            myCell.settingSwitch.setOn(false, animated: false)
                        }
                    }
                    return cell
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = tableView.cellForRow(at: indexPath) as! SettingsTableViewCell
        if selected.settingName.text == "Profile"{
            self.performSegue(withIdentifier: "profile", sender: self)
        }
        else if selected.settingName.text == "Shop Profile"{
            self.performSegue(withIdentifier: "profileShop", sender: self)
        }
//        else if selected.settingName.text == "Change Password"{
//            self.performSegue(withIdentifier: "changePassword", sender: self)
//        }
//        else if selected.settingName.text == "Change Address"{
//            self.performSegue(withIdentifier: "changeAddress", sender: self)
//        }
        else if selected.settingName.text == "Logout"{
            let alert = UIAlertController(title: "Alert", message: "Are you sure you want to logout?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action:UIAlertAction)->Void in
                let myUrl = URL(string: "\(self.shopeeng.ipAddress)logout")
                var request = URLRequest(url:myUrl!)
                request.httpMethod = "POST"
                request.setValue("Bearer \(UserDefaults.standard.string(forKey: "Token")!)", forHTTPHeaderField: "Authorization")
                
                let size = CGSize(width: 40, height: 40)
                self.startAnimating(size, message: "Please Wait", messageFont: UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.regular), type: NVActivityIndicatorType.ballPulse, color: self.delegate.themeColor, padding: NVActivityIndicatorView.DEFAULT_PADDING, displayTimeThreshold: NVActivityIndicatorView.DEFAULT_BLOCKER_DISPLAY_TIME_THRESHOLD, minimumDisplayTime: NVActivityIndicatorView.DEFAULT_BLOCKER_MINIMUM_DISPLAY_TIME, backgroundColor: NVActivityIndicatorView.DEFAULT_BLOCKER_BACKGROUND_COLOR, textColor: NVActivityIndicatorView.DEFAULT_TEXT_COLOR)
                
                URLSession.shared.dataTask(with: request) {
                    (data: Data?, response: URLResponse?, error: Error?) in
                    
                    if error != nil
                    {
                        print("error=\(error!)")
                        return
                    }
                    
                    guard let data = data else {return}
                    
                    var message = ""
                    
                    do {
                        let info = try JSONDecoder().decode(Logout.self, from: data)
                        
                        if(info.error == nil){
                            message = info.info!
                        }
                        else{
                            message = info.error!
                        }
                        
                        UserDefaults.standard.removeObject(forKey: "Id")
                        UserDefaults.standard.removeObject(forKey: "Role")
                        UserDefaults.standard.removeObject(forKey: "Token")
                        UserDefaults.standard.removeObject(forKey: "ShopId")
                        UserDefaults.standard.set(false, forKey: "SecureApps")
                        UserDefaults.standard.set(false, forKey: "LoggedIn")
                        UserDefaults.standard.synchronize()
                    }
                    catch {
                        print("Error deserializing JSON: \(error)")
                    }
                    
                    OperationQueue.main.addOperation({
                        print(message)
                        self.stopAnimating()
                        self.performSegue(withIdentifier: "logout", sender: self)
                    })
                }.resume()
                
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: { (action:UIAlertAction)->Void in
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // Override to support editing the table view.
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            // Delete the row from the data source
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }

}
