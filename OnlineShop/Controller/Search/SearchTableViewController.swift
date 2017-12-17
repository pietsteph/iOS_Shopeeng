//
//  SearchTableViewController.swift
//  OnlineShop
//
//  Created by Pieter Stephenson on 18/12/17.
//  Copyright © 2017 Pieter Stephenson. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController {
    
    let shopeeng = Shopeeng()
    var shops = [ShopModel]()
    var keyword = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        }
        
        self.navigationItem.title = keyword
        
        shopeeng.searchShope(keyword: keyword) { (result) in
            self.shops = result
            self.tableView.reloadData()
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
        return shops.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchTableViewCell

        cell.name.text = shops[indexPath.row].name
        cell.owner.text = shops[indexPath.row].owner
        cell.selling.text = "Selling \(shops[indexPath.row].selling) Products"

        return cell
    }

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
        var destination = segue.destination
        if let navController = segue.destination as? UINavigationController{
            destination = navController.visibleViewController ?? destination
        }
        
        if let vc = destination as? ShopViewController{
            guard let cell = sender as? SearchTableViewCell else {return}
            guard let indexPath = self.tableView!.indexPath(for: cell) else {return}
            
            vc.navigationItem.title = shops[indexPath.row].name
            vc.shop = shops[indexPath.row]
        }
    }

}
