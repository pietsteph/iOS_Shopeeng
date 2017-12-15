//
//  CreditsViewController.swift
//  OnlineShop
//
//  Created by Pieter Stephenson on 27/11/17.
//  Copyright © 2017 Pieter Stephenson. All rights reserved.
//

import UIKit

class CreditsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let refreshControl = UIRefreshControl()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    let shopeeng = Shopeeng()
    let topup_list:[Int] = [5000, 10000, 25000, 50000, 100000, 200000, 500000]
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var topup = false
    
    @IBOutlet weak var credits: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topup_list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TopupCell", for: indexPath)
        
        if let myCell = cell as? CreditsTableViewCell{
            let bgColorView = UIView()
            bgColorView.backgroundColor = delegate.themeColor
            myCell.selectedBackgroundView = bgColorView
            myCell.icon.image = UIImage(named: "credits")
            myCell.topup.text = "Topup " + addThousandSeparator(integer: topup_list[indexPath.row])
        }
        
        return cell
    }
    
    func addThousandSeparator(integer:Int)->String{
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        let stringTopup = formatter.string(from: NSNumber(value: integer))
        return stringTopup!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Topup", message: "Are you sure you want to topup \(addThousandSeparator(integer: topup_list[indexPath.row])) to your account?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action:UIAlertAction)->Void in
            
            self.view.addSubview(self.activityIndicator)
            self.activityIndicator.frame = self.view.bounds
            self.activityIndicator.startAnimating()
            
            let myUrl = URL(string: self.shopeeng.URL_TOPUP)
            var request = URLRequest(url:myUrl!)
            request.httpMethod = "POST"
            
            let userId = Int(UserDefaults.standard.string(forKey: "Id")!)
            let postString = "id=\(userId!)&topup=\(self.topup_list[indexPath.row])";
            request.httpBody = postString.data(using: String.Encoding.utf8);
            
            URLSession.shared.dataTask(with: request) {
                (data: Data?, response: URLResponse?, error: Error?) in
                
                if error != nil
                {
                    print("error=\(error!)")
                    return
                }
                else{
                    do {
                        let parsedData = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                        if let result = parsedData["result"] as? Int {
                            self.topup = result == 1 ? true : false
                        }
                    }
                    catch {
                        print("Error deserializing JSON: \(error)")
                    }
                }
                
                OperationQueue.main.addOperation({
                    //calling another function after fetching the json
                    self.activityIndicator.stopAnimating()
                    if(self.topup){
                        self.errorAlert(message: "You are successfully topup \(self.addThousandSeparator(integer: self.topup_list[indexPath.row])) to your account")
                        self.fetchCredits(){
                            credits in
                            OperationQueue.main.addOperation({
                                //calling another function after fetching the json
                                self.activityIndicator.stopAnimating()
                                self.credits.text = "\(self.addThousandSeparator(integer: credits))"
                            })
                        }
                    }
                    else{
                        self.errorAlert(message: "Unknown error. Your transaction has been terminated")
                    }
                })
            }.resume()
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action:UIAlertAction)->Void in
            
        }))
        self.present(alert, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func errorAlert(message:String){
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action:UIAlertAction)->Void in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func fetchCredits(completion: @escaping (_ credits: Int) -> Void){
        let myUrl = URL(string: self.shopeeng.URL_PROFILE)
        var request = URLRequest(url:myUrl!)
        request.httpMethod = "POST"
        let postString = "id=\(UserDefaults.standard.string(forKey: "Id")!)&token=\(UserDefaults.standard.string(forKey: "Token")!)";
        request.httpBody = postString.data(using: String.Encoding.utf8);
        
        URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            var credits = Int()
            
            if error != nil
            {
                print("error=\(error!)")
                return
            }
            
            guard let data = data else {return}
            
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                credits = user.credits!
            }
            catch {
                print("Error deserializing JSON: \(error)")
            }
            
            OperationQueue.main.addOperation({
                completion(credits)
            })
        }.resume()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.frame = self.view.bounds
        self.activityIndicator.startAnimating()
        
        fetchCredits(){
            credits in
            OperationQueue.main.addOperation({
                //calling another function after fetching the json
                self.activityIndicator.stopAnimating()
                self.credits.text = "\(self.addThousandSeparator(integer: credits))"
            })
        }
    }
    
     @objc func refresh(){
        fetchCredits(){
            credits in
            OperationQueue.main.addOperation({
                //calling another function after fetching the json
                self.refreshControl.endRefreshing()
                self.credits.text = "\(self.addThousandSeparator(integer: credits))"
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
