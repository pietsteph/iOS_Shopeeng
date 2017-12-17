//
//  ShopViewController.swift
//  OnlineShop
//
//  Created by Pieter Stephenson on 18/12/17.
//  Copyright © 2017 Pieter Stephenson. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class ShopViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NVActivityIndicatorViewable {
    
    @IBOutlet weak var shopName: UILabel!
    @IBOutlet weak var shopDescription: UILabel!
    @IBOutlet weak var shopProducts: UICollectionView!
    
    var shop = ShopModel()
    var products = [ProductModel]()
    let shopeeng = Shopeeng()
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBAction func callShop(_ sender: Any) {
        guard let number = URL(string: "tel://\(shop.phone)") else { return }
        UIApplication.shared.open(number)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shopProducts.delegate = self
        shopProducts.dataSource = self
        
        shopName.text = shop.name
        shopName.lineBreakMode = .byWordWrapping
        shopName.sizeToFit()
        
        shopDescription.text = shop.description
        shopDescription.lineBreakMode = .byWordWrapping
        shopDescription.sizeToFit()
        
        shopeeng.myProducts(shop_id: shop.id) { (result) in
            self.products = result
            self.shopProducts.reloadData()
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShopItemCell", for: indexPath) as! ShopCollectionViewCell
        
        let frame = CGRect(x: cell.image.center.x-20, y: cell.image.center.y-20, width: 20, height: 20)
        let loader = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.ballPulseSync, color: delegate.themeColor, padding: NVActivityIndicatorView.DEFAULT_PADDING)
        cell.image.addSubview(loader)
        loader.startAnimating()
        
        let id = products[indexPath.row].id
        let token = UserDefaults.standard.string(forKey: "Token")
        let url = URL(string: "\(shopeeng.ipAddress)product/image/\(id)")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask( with: request, completionHandler: {
            (data, response, error) -> Void in
            guard let data = data, error == nil else {
                return
            }
            DispatchQueue.main.async {
                cell.image.contentMode = .scaleAspectFit
                cell.image.image = UIImage(data: data)
                loader.stopAnimating()
            }
        }).resume()
        
        cell.title.text = products[indexPath.row].name
        let priceString = shopeeng.priceToString(integer: products[indexPath.row].price)
        cell.price.text = "Rp. \(priceString)"
        
        return cell
    }
    
    private let itemsPerRow:CGFloat = 3
    private let sectionInsets:UIEdgeInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: 160)
    }
    
    func collectionView(_ collectionView: UICollectionView, collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destination = segue.destination
        if let navController = segue.destination as? UINavigationController{
            destination = navController.visibleViewController ?? destination
        }
        
        if let vc = destination as? DetailViewController{
            guard let cell = sender as? ShopCollectionViewCell else {return}
            guard let indexPath = self.shopProducts!.indexPath(for: cell) else {return}
            vc.navigationItem.title = products[indexPath.row].name
            vc.product = products[indexPath.row]
        }
    }

}
