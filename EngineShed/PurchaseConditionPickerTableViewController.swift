//
//  PurchaseConditionPickerTableViewController.swift
//  EngineShed
//
//  Created by Scott James Remnant on 3/4/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

class PurchaseConditionPickerTableViewController : UITableViewController {

    var purchase: Purchase? {
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
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return PurchaseCondition.allCases.count
        default: preconditionFailure("Unexpected section: \(section)")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "purchaseConditionCase", for: indexPath)

        switch indexPath.section {
        case 0:
            cell.textLabel?.text = "None"
            cell.accessoryType = purchase?.condition == nil ? .checkmark : .none
        case 1:
            let condition = PurchaseCondition.allCases[indexPath.row]
            cell.textLabel?.text = "\(condition)"
            cell.accessoryType = purchase?.condition == condition ? .checkmark : .none
        default: preconditionFailure("Unexpected indexPath: \(indexPath)")
        }

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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentIndexPath: IndexPath
        switch purchase?.condition {
        case nil: currentIndexPath = IndexPath(row: 0, section: 0)
        case let condition?:
            guard let row = PurchaseCondition.allCases.firstIndex(of: condition) else { preconditionFailure("Condition not in allCases") }
            currentIndexPath = IndexPath(row: row, section: 1)
        }

        if let cell = tableView.cellForRow(at: currentIndexPath) {
            cell.accessoryType = .none
        }

        switch indexPath.section {
        case 0:
            purchase?.condition = nil
        case 1:
            purchase?.condition = PurchaseCondition.allCases[indexPath.row]
        default: preconditionFailure("Unexpected indexPath: \(indexPath)")
        }

        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
