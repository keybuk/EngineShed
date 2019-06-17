//
//  ModelDispositionPickerTableViewController.swift
//  EngineShed
//
//  Created by Scott James Remnant on 3/9/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

class ModelDispositionPickerTableViewController : UITableViewController {

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
        case 1: return ModelDisposition.allCases.count
        default: preconditionFailure("Unexpected section: \(section)")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "modelDispositionCase", for: indexPath)

        switch indexPath.section {
        case 0:
            cell.textLabel?.text = "None"
            cell.accessoryType = model?.disposition == nil ? .checkmark : .none
        case 1:
            let disposition = ModelDisposition.allCases[indexPath.row]
            cell.textLabel?.text = "\(disposition)"
            cell.accessoryType = model?.disposition == disposition ? .checkmark : .none
        default: preconditionFailure("Unexpected indexPath: \(indexPath)")
        }

        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentIndexPath: IndexPath
        switch model?.disposition {
        case nil: currentIndexPath = IndexPath(row: 0, section: 0)
        case let disposition?:
            guard let row = ModelDisposition.allCases.firstIndex(of: disposition) else { preconditionFailure("Disposition not in allCases") }
            currentIndexPath = IndexPath(row: row, section: 1)
        }

        if let cell = tableView.cellForRow(at: currentIndexPath) {
            cell.accessoryType = .none
        }

        switch indexPath.section {
        case 0:
            model?.disposition = nil
        case 1:
            model?.disposition = ModelDisposition.allCases[indexPath.row]
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
