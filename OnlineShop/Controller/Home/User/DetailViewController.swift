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
    
    var product = ProductModel()
    let shopeeng = Shopeeng()
    
    var productId:Int?
    var productTitle:String?
    var productPrice:String?
    var productDesc:String?
    var productRate:Double?
    var productRateText:String?
    var productURL:String?
    var tempImg:UIImage?{
        didSet{
            self.image.image = tempImg
        }
    }
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    let shapeLayer = CAShapeLayer()
    let trackLayer = CAShapeLayer()
    var activityIndicator:NVActivityIndicatorView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        }
        
        name.sizeToFit()
        descriptions.sizeToFit()
        
//        name.text = productTitle ?? "Default"
//        price.text = productPrice ?? "Rp. 0"
//        descriptions.text = productDesc ?? "Default"
//        rating.rating = productRate ?? 0.0
//        rating.text = productRateText ?? "0.0"
//        image.lazyLoadImage(link: productURL ?? "", contentMode: .scaleAspectFit)
        
        name.text = product.name
        price.text = "Rp. \(shopeeng.priceToString(integer: product.price))"
        descriptions.text = product.description
        rating.rating = product.rating
        rating.text = "\(product.rating)"
 
        let frame = CGRect(x: image.center.x-40, y: image.center.y-40, width: 40, height: 40)
        activityIndicator = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.ballPulseSync, color: delegate.themeColor, padding: NVActivityIndicatorView.DEFAULT_PADDING)
        image.addSubview(activityIndicator!)
        downloadImage()
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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
