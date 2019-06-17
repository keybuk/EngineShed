//
//  ModelClassificationPickerTableViewController.swift
//  EngineShed
//
//  Created by Scott James Remnant on 3/9/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

class ModelClassificationPickerTableViewController : UITableViewController {

    var model: Model?

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
        case 1: return ModelClassification.allCases.count
        default: preconditionFailure("Unexpected section: \(section)")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "modelClassificationCase", for: indexPath)

        switch indexPath.section {
        case 0:
            cell.textLabel?.text = "None"
            cell.accessoryType = model?.classification == nil ? .checkmark : .none
        case 1:
            let classification = ModelClassification.allCases[indexPath.row]
            cell.textLabel?.text = "\(classification)"
            cell.accessoryType = model?.classification == classification ? .checkmark : .none
        default: preconditionFailure("Unexpected indexPath: \(indexPath)")
        }

        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentIndexPath: IndexPath
        switch model?.classification {
        case nil: currentIndexPath = IndexPath(row: 0, section: 0)
        case let classification?:
            guard let row = ModelClassification.allCases.firstIndex(of: classification) else { preconditionFailure("Classification not in allCases") }
            currentIndexPath = IndexPath(row: row, section: 1)
        }

        if let cell = tableView.cellForRow(at: currentIndexPath) {
            cell.accessoryType = .none
        }

        switch indexPath.section {
        case 0:
            model?.classification = nil
        case 1:
            model?.classification = ModelClassification.allCases[indexPath.row]
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
