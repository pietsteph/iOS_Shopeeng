//
//  DetailViewController.swift
//  OnlineShop
//
//  Created by Pieter Stephenson on 13/12/17.
//  Copyright © 2017 Pieter Stephenson. All rights reserved.
//

import UIKit
import Cosmos
import NVActivityIndicatorView

class DetailViewController: UIViewController, NVActivityIndicatorViewable {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var descriptions: UILabel!
    @IBOutlet weak var sold: UILabel!
    @IBOutlet weak var viewed: UILabel!
    @IBOutlet weak var insurance: UILabel!
    @IBOutlet weak var weight: UILabel!
    @IBOutlet weak var condition: UILabel!
    @IBOutlet weak var btnBuy: UIButton!
    
    var product = ProductModel()
    let shopeeng = Shopeeng()
    var tempImg:UIImage?{
        didSet{
            self.image.image = tempImg
        }
    }
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var activityIndicator:NVActivityIndicatorView? = nil
    
    @IBAction func buyProduct(_ sender: UIButton) {
        loadProduct()
        if product.stock <= 0{
            let alert = UIAlertController(title: "Purchase Failed", message: "This product has been sold out", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action:UIAlertAction)->Void in
                    
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else{
            performSegue(withIdentifier: "buy", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        }
        
        name.sizeToFit()
        descriptions.sizeToFit()
        
        loadInfo()
        
        downloadImage()
        loadProduct()
    }
    
    func loadInfo(){
        name.text = product.name
        price.text = "Rp. \(shopeeng.priceToString(integer: product.price))"
        descriptions.text = product.description
        rating.rating = product.rating
        rating.text = "\(product.review) Review"
        viewed.text = "\(product.view)"
        sold.text = "\(product.sold)"
        weight.text = "\(product.heavy)"
        condition.text = "Condition: \(product.condition.firstUppercased)"
        
        switch product.is_insurance {
        case 0:
            insurance.text = "No"
        default:
            insurance.text = "Yes"
        }
    }
    
    func loadProduct(){
        let size = CGSize(width: 40, height: 40)
        startAnimating(size, message: "Please Wait", messageFont: UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.regular), type: NVActivityIndicatorType.ballPulse, color: delegate.themeColor, padding: NVActivityIndicatorView.DEFAULT_PADDING, displayTimeThreshold: NVActivityIndicatorView.DEFAULT_BLOCKER_DISPLAY_TIME_THRESHOLD, minimumDisplayTime: NVActivityIndicatorView.DEFAULT_BLOCKER_MINIMUM_DISPLAY_TIME, backgroundColor: NVActivityIndicatorView.DEFAULT_BLOCKER_BACKGROUND_COLOR, textColor: NVActivityIndicatorView.DEFAULT_TEXT_COLOR)
        
        shopeeng.productInfo(product_id: product.id) { (result) in
            self.product = result[0]
            self.loadInfo()
            self.stopAnimating()
        }
    }
    
    func downloadImage(){
        activityIndicator?.startAnimating()
        guard let url = URL(string: product.imageURL) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                self.tempImg = UIImage(data: data)
                self.activityIndicator?.stopAnimating()
            }
        }.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! BuyTableViewController
        vc.product = self.product
    }
}

extension String {
    var firstUppercased: String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }
}
