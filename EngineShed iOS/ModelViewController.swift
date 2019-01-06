//
//  ModelViewController.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 9/17/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import UIKit
import CoreData

import Database

protocol ModelSettable : class {

    var model: Model? { get set }

}

class ModelViewController : UITableViewController {

    var persistentContainer: NSPersistentContainer?

    var model: Model? {
        didSet {
            // Update the view.
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

        tableView.register(UINib(nibName: "ElectricalHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "electricalHeaderView")
    }

    func configureView() {

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 10
        case 1: return 2
        default: preconditionFailure("Unexpected section: \(section)")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier: String
        switch (indexPath.section, indexPath.row) {
        case (0, 0): identifier = "modelImageCell"
        case (0, 1): identifier = "modelPurchaseCell"
        case (0, 2): identifier = "modelClassificationCell"
        case (0, 3): identifier = "modelClassCell"
        case (0, 4): identifier = "modelNumberCell"
        case (0, 5): identifier = "modelNameCell"
        case (0, 6): identifier = "modelLiveryCell"
        case (0, 7): identifier = "modelDetailsCell"
        case (0, 8): identifier = "modelEraCell"
        case (0, 9): identifier = "modelDispositionCell"
        // Electrical
        case (1, 0): identifier = "modelMotorCell"
        case (1, 1): identifier = "modelLightsCell"
        default: preconditionFailure("Unexpected indexPath: \(indexPath)")
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! UITableViewCell & ModelSettable
        cell.model = model
        return cell
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let identifier: String
        switch section {
        case 0: return nil
        case 1: identifier = "electricalHeaderView"
        default: preconditionFailure("Unexpected section: \(section)")
        }

        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier)
        return view
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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
