//
//  HomeTableViewController.swift
//  OnlineShop
//
//  Created by Pieter Stephenson on 04/12/17.
//  Copyright © 2017 Pieter Stephenson. All rights reserved.
//

import UIKit

extension UIImageView {
    func lazyLoadImage(link:String, contentMode: UIViewContentMode){

        URLSession.shared.dataTask( with: URL(string: link)!, completionHandler: {
            (data, response, error) -> Void in

            guard let data = data, error == nil else {
                return
            }

            DispatchQueue.main.async {
                self.contentMode =  contentMode
                self.image = UIImage(data: data) ?? UIImage(named: "cached")
            }
        }).resume()
    }
}

class HomeTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    let shopeeng = Shopeeng()
    var products = [ProductModel]()
    var filteredProducts = [ProductModel]()
    
    var refresher : UIRefreshControl!
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    let searchController = UISearchController(searchResultsController: nil)
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    let memory = 500*1024*1024
    let disk = 500*1024*1024
    var urlCache = URLCache()
    let cache = NSCache<AnyObject, UIImage>()
    
    @objc func refresh(){
        urlCache.removeAllCachedResponses()
//        cache.removeAllObjects()
        shopeeng.myProducts(shop_id: UserDefaults.standard.integer(forKey: "ShopId")) { (results) in
            DispatchQueue.main.async {
                self.products = results
                self.filteredProducts = self.products
                UIView.transition(with: self.tableView,
                                  duration: 0.35,
                                  options: UIViewAnimationOptions.transitionFlipFromLeft,
                                  animations: { self.tableView.reloadData() })
                self.refresher.endRefreshing()
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationItem.titleView = nil
        self.navigationItem.rightBarButtonItems = [addButton, searchButton]
    }
    
    @objc func addProduct(){
        performSegue(withIdentifier: "addProduct", sender: self)
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
    
    var searchButton = UIBarButtonItem()
    var addButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add Right Bar Button Item
        searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showSearchBar))
        addButton = UIBarButtonItem(image:#imageLiteral(resourceName: "add") , style: .plain, target: self, action: #selector(addProduct))
        navigationItem.rightBarButtonItems = [addButton, searchButton]
        
        //Setup URL Cache
        urlCache = URLCache(memoryCapacity: memory, diskCapacity: disk, diskPath: "myDiskPath")
        URLCache.shared = urlCache
        
        //Large Navigation Title
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        //Search Controller Setup
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = delegate.themeColor
        searchController.searchBar.searchBarStyle = .minimal
        searchController.hidesNavigationBarDuringPresentation = false
        
//        self.definesPresentationContext = true
        
        //Refresh Control
        refresher = UIRefreshControl()
        if #available(iOS 10.0, *) {
            self.refreshControl = refresher
        } else {
            tableView.addSubview(refresher)
        }
        self.extendedLayoutIncludesOpaqueBars = true
        
        self.refresher?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refresher.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        
        //Table View Setup
        tableView.tableFooterView = UIView()
        loadList()
        
        //Notification to reload
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "loadMyProduct"), object: nil)
        
        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = true

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            filteredProducts = products.filter { prod in
                return prod.name.lowercased().contains(searchText.lowercased())
            }
            tableView.reloadData()
        } else {
            filteredProducts = products
            tableView.reloadData()
        }
        
    }
    
    @objc func loadList(){
        self.tableView.addSubview(self.activityIndicator)
        self.activityIndicator.frame = self.tableView.bounds
        self.activityIndicator.startAnimating()
        shopeeng.myProducts(shop_id: UserDefaults.standard.integer(forKey: "ShopId")) { (results) in
            self.products = results
            self.filteredProducts = self.products
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
        }
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
        return filteredProducts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)

        let myCell = cell as! HomeTableViewCell
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = delegate.themeColor
        myCell.selectedBackgroundView = bgColorView

        myCell.imageProduct.lazyLoadImage(link: filteredProducts[indexPath.row].imageURL, contentMode: .scaleAspectFit)

        myCell.title.text = filteredProducts[indexPath.row].name
        let price = shopeeng.priceToString(integer: filteredProducts[indexPath.row].price)
        myCell.price.text = "Rp. \(price)"
        
        myCell.imageStar.image = UIImage(named: "star")?.withRenderingMode(.alwaysTemplate)
        myCell.imageStar.tintColor = .yellow
        myCell.rating.text = "\(filteredProducts[indexPath.row].rating)"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(filteredProducts[indexPath.row].name)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // Override to support conditional editing of the table view.
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        // Return false if you do not want the specified item to be editable.
//        return true
//    }

    // Override to support editing the table view.
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            // Delete the row from the data source
//            filteredProducts.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }
//    }

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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
