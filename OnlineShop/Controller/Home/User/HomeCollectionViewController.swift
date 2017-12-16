//
//  HomeCollectionViewController.swift
//  OnlineShop
//
//  Created by Pieter Stephenson on 12/12/17.
//  Copyright © 2017 Pieter Stephenson. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

private let reuseIdentifier = "HomeItemCell"

class HomeCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, NVActivityIndicatorViewable {
    
    var headers:[String] = ["Popular Items", "New Items"]
    private var searches = [ProductModel]()
    let shopeeng = Shopeeng()
    var products = [[ProductModel]]()
    
    var refresher : UIRefreshControl!
    let activityIndicator:NVActivityIndicatorView? = nil
    let searchController = UISearchController(searchResultsController: nil)
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    let memory = 500*1024*1024
    let disk = 500*1024*1024
    var urlCache = URLCache()
    let cache = NSCache<AnyObject, UIImage>()
    
    var searchButton = UIBarButtonItem()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showSearchBar))
        navigationItem.rightBarButtonItem = searchButton
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        //Search Controller Setup
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = delegate.themeColor
        searchController.searchBar.searchBarStyle = .minimal
        searchController.hidesNavigationBarDuringPresentation = false
        
        //Refresh Control
        refresher = UIRefreshControl()
        if #available(iOS 10.0, *) {
            self.collectionView?.refreshControl = refresher
        } else {
            self.collectionView?.addSubview(refresher)
        }
        self.extendedLayoutIncludesOpaqueBars = true
        
        self.refresher?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refresher.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        
        loadHomeCollectionView()
    }
    
    @objc func showSearchBar(){
        UIView.animate(withDuration: 0.5, animations: {
            self.navigationItem.rightBarButtonItems = nil
        }) { (finished) in
            self.navigationItem.titleView = UIView()
            UIView.transition(with: self.navigationItem.titleView!, duration: 0.5, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
                self.navigationItem.titleView = self.searchController.searchBar
                self.searchController.searchBar.becomeFirstResponder()
            })
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationItem.titleView = nil
        self.navigationItem.rightBarButtonItem = searchButton
    }
    
    @objc func loadHomeCollectionView(){
        let size = CGSize(width: 40, height: 40)
        startAnimating(size, message: "Please Wait", messageFont: UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.regular), type: NVActivityIndicatorType.ballPulse, color: delegate.themeColor, padding: NVActivityIndicatorView.DEFAULT_PADDING, displayTimeThreshold: NVActivityIndicatorView.DEFAULT_BLOCKER_DISPLAY_TIME_THRESHOLD, minimumDisplayTime: NVActivityIndicatorView.DEFAULT_BLOCKER_MINIMUM_DISPLAY_TIME, backgroundColor: NVActivityIndicatorView.DEFAULT_BLOCKER_BACKGROUND_COLOR, textColor: NVActivityIndicatorView.DEFAULT_TEXT_COLOR)
        shopeeng.homeCollection { (result) in
            DispatchQueue.main.async {
                self.products = result
                self.collectionView?.reloadData()
                self.stopAnimating()
            }
        }
    }
    
    @objc func refresh(){
        urlCache.removeAllCachedResponses()
//        cache.removeAllObjects()
        shopeeng.homeCollection { (result) in
            DispatchQueue.main.async {
                self.products = result
                self.collectionView?.reloadData()
                UIView.transition(with: (self.collectionView)!,
                                  duration: 0.35,
                                  options: UIViewAnimationOptions.transitionFlipFromLeft,
                                  animations: { self.collectionView?.reloadData() })
                self.refresher.endRefreshing()
            }
        }
    }
    
    @objc func dismissKeyboard() {
        self.navigationItem.searchController?.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.navigationItem.searchController?.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destination = segue.destination
        if let navController = segue.destination as? UINavigationController{
            destination = navController.visibleViewController ?? destination
        }

        if let vc = destination as? DetailViewController{
            guard let cell = sender as? HomeCollectionViewCell else {return}
            guard let indexPath = self.collectionView!.indexPath(for: cell) else {return}
            vc.navigationItem.title = products[indexPath.section][indexPath.row].name
            
            vc.product = products[indexPath.section][indexPath.row]
            
//            vc.productId = products[indexPath.section][indexPath.row].id
//            vc.productTitle = products[indexPath.section][indexPath.row].name
//            vc.productPrice = addThousandSeparator(integer: products[indexPath.section][indexPath.row].price)
//            vc.productDesc = products[indexPath.section][indexPath.row].description
//            vc.productRate = products[indexPath.section][indexPath.row].rating
//            vc.productRateText = "\(products[indexPath.section][indexPath.row].rating)"
//            vc.productURL = products[indexPath.section][indexPath.row].imageURL
        }
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return products.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return products[section].count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HomeCollectionViewCell
        
        let frame = CGRect(x: cell.image.center.x-20, y: cell.image.center.y-20, width: 20, height: 20)
        let loader = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.ballPulseSync, color: delegate.themeColor, padding: NVActivityIndicatorView.DEFAULT_PADDING)
        cell.image.addSubview(loader)
        loader.startAnimating()
        
        let url = products[indexPath.section][indexPath.row].imageURL
        
        URLSession.shared.dataTask( with: URL(string: url!)!, completionHandler: {
            (data, response, error) -> Void in
            
            guard let data = data, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                cell.image.image = UIImage(data: data)
                loader.stopAnimating()
            }
        }).resume()
        cell.image.contentMode = .scaleAspectFit
        cell.title.text = products[indexPath.section][indexPath.row].name
        let priceString = shopeeng.priceToString(integer: products[indexPath.section][indexPath.row].price)
        cell.price.text = "Rp. \(priceString)"
    
        return cell
    }
    
    private let itemsPerRow:CGFloat = 3
    private let sectionInsets:UIEdgeInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as? SectionHeaderCollectionReusableView{
            sectionHeader.header = headers[indexPath.section]
            return sectionHeader
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: 160)
    }
    
    func collectionView(_ collectionView: UICollectionView, collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return true
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
}
