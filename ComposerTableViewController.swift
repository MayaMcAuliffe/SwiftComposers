//
//  ComposerTableViewController.swift
//  composers
//
//  Created by Maya McAuliffe on 6/11/18.
//  Copyright © 2018 Maya McAuliffe. All rights reserved.
//

import UIKit

class ComposerTableViewController: UITableViewController {
    
    // Mark: Properties
    var composers = [Composer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadComposerList()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

     //MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Rhe number of rows in the table should be the number of composer I want to display
        return composers.count
    }

    // This function displays the cell at each row, and deals with the fact that not all cells may be visible at once
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
   
        let cellIdentifier = "ComposerTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ComposerTableViewCell else {
            fatalError("The dequeued cell is not an instance of ComposedTableViewCell")
        }
        
        let composer = composers[indexPath.row]
        cell.nameButton.setTitle(composer.name, for: .normal)
        
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // Mark: Private Methods
    private func loadComposerList() {
        let composer1 = Composer(name: "Motzart")
        let composer2 = Composer(name: "Beethovan")
        let composer3 = Composer(name: "Brahms")
        let composer4 = Composer(name: "Tchaikovsky")  //1840
        let composer5 = Composer(name: "Prokofiev") //1891
        let composer6 = Composer(name: "Mahler")
        let composer7 = Composer(name: "Bach")
        
        composers += [composer1, composer2, composer3, composer4, composer5, composer6, composer7]
    }

}
