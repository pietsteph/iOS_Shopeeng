//
//  BuyTableViewController.swift
//  OnlineShop
//
//  Created by Pieter Stephenson on 17/12/17.
//  Copyright © 2017 Pieter Stephenson. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class BuyTableViewController: UITableViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var stepperAmount: UIStepper!
    @IBOutlet weak var amount: UILabel!
    
    @IBOutlet weak var courier: UILabel!
    @IBOutlet weak var barItem: UIBarButtonItem!
    
    @IBOutlet weak var unitPrice: UILabel!
    @IBOutlet weak var totalPrice: UILabel!
    @IBOutlet weak var shipping: UILabel!
    @IBOutlet weak var grandTotal: UILabel!
    
    var product = ProductModel()
    let shopeeng = Shopeeng()
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var totals = 0;
    var courierSelection:String?{
        willSet{
            courier.text = newValue
            
            switch newValue {
            case "JNE"?:
                deliveryId = 1
                shippingFee = 20000
            case "TIKI"?:
                deliveryId = 2
                shippingFee = 10000
            case "Go Jek"?:
                deliveryId = 3
                shippingFee = 15000
            default:
                deliveryId = 0
                shippingFee = 0
            }
            
            shipping.text = "Rp. \(shopeeng.priceToString(integer: shippingFee))"
            grandTotal.text = "Rp. \(shopeeng.priceToString(integer: totals+shippingFee))"
            
            barItem.isEnabled = true
        }
    }
    
    var deliveryId = 0;
    var shippingFee = 0;
    
    @IBAction func stepper(_ sender: Any) {
        amount.text = "\(Int(stepperAmount.value))"
        
        totals = product.price * Int(stepperAmount.value)
        totalPrice.text = "Rp. \(shopeeng.priceToString(integer: totals))"
        grandTotal.text = "Rp. \(shopeeng.priceToString(integer: totals+shippingFee))"
    }
    
    @IBAction func buy(_ sender: Any) {
        guard deliveryId != 0, let url = URL(string: "\(shopeeng.ipAddress)transaction"), let token = UserDefaults.standard.string(forKey: "Token") else { return }
        let id = UserDefaults.standard.integer(forKey: "Id")
        
        let parameters = ["user_id": id, "product_id": product.id, "delivery_id": deliveryId, "amount": Int(stepperAmount.value)]
        
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
        
        let size = CGSize(width: 40, height: 40)
        startAnimating(size, message: "Please Wait", messageFont: UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.regular), type: NVActivityIndicatorType.ballPulse, color: delegate.themeColor, padding: NVActivityIndicatorView.DEFAULT_PADDING, displayTimeThreshold: NVActivityIndicatorView.DEFAULT_BLOCKER_DISPLAY_TIME_THRESHOLD, minimumDisplayTime: NVActivityIndicatorView.DEFAULT_BLOCKER_MINIMUM_DISPLAY_TIME, backgroundColor: NVActivityIndicatorView.DEFAULT_BLOCKER_BACKGROUND_COLOR, textColor: NVActivityIndicatorView.DEFAULT_TEXT_COLOR)
        
        URLSession.shared.dataTask(with: request) {
            (data: Data?, response: URLResponse?, error: Error?) in
            
            guard let data = data, error == nil else {return}
            
            var message = ""
            var warning = ""
            
            do{
                let json = try JSONDecoder().decode(Buy.self, from: data)
                
                if (json.warning == nil){
                    message = "Success purchasing \(self.product.name)"
                }
                else{
                    warning = "Purchase failed"
                }
            }
            catch{
                print("Error deserializing json: \(error)")
            }
            
            OperationQueue.main.addOperation({
                //calling another function after fetching the json
                self.stopAnimating()
                if(warning == ""){
                    self.errorAlert(message: message, code: 1)
                }
                else{
                    self.errorAlert(message: warning, code: 0)
                }
            })
            }.resume()
    }
    
    func errorAlert(message:String, code:Int){
        let alert = UIAlertController(title: "Purchase", message: message, preferredStyle: .alert)
        if code == 1{
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action:UIAlertAction)->Void in
                CATransaction.setCompletionBlock({
//                    self.navigationController?.popViewController(animated: true)
//                    self.dismiss(animated: true, completion: nil)
                    self.performSegue(withIdentifier: "backToHome", sender: self)
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
        
        barItem.isEnabled = false
        
        stepperAmount.stepValue = 1
        stepperAmount.minimumValue = 1
        stepperAmount.maximumValue = Double(product.stock)
        stepperAmount.autorepeat = true

        totals = product.price * Int(stepperAmount.value)

        name.text = product.name
        unitPrice.text = "Rp. \(shopeeng.priceToString(integer: product.price))"
        totalPrice.text = "Rp. \(shopeeng.priceToString(integer: totals))"
        shipping.text = "-"
        grandTotal.text = "Rp. \(shopeeng.priceToString(integer: totals+shippingFee))"
    }
    
    @IBAction func unwindToThisView(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? CourierTableViewController {
            self.courierSelection = sourceViewController.selected
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}
