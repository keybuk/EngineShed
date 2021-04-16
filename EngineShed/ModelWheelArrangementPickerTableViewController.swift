//
//  ModelWheelArrangementPickerTableViewController.swift
//  EngineShed
//
//  Created by Scott James Remnant on 4/16/21.
//  Copyright © 2021 Scott James Remnant. All rights reserved.
//

import UIKit

import Database

class ModelWheelArrangementPickerTableViewController : UITableViewController {

    var model: Model?

    lazy var wheelArrangements: [String] = { model?.suggestionsForWheelArrangement() ?? [] }()
    var extraWheelArrangement: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        // If the current model wheel arrangement isn't in the suggestions, place it as an extra row in the first section and keep it there.
        if let wheelArrangement = model?.wheelArrangement,
            !wheelArrangements.contains(wheelArrangement)
        {
            extraWheelArrangement = wheelArrangement
        }

        super.viewWillAppear(animated)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1 + (extraWheelArrangement != nil ? 1 : 0)
        case 1: return wheelArrangements.count
        default: preconditionFailure("Unexpected section: \(section)")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "modelWheelArrangement", for: indexPath)

        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "None"
                cell.accessoryType = (model?.wheelArrangement?.isEmpty ?? true) ? .checkmark : .none
            case 1:
                cell.textLabel?.text = extraWheelArrangement
                cell.accessoryType = model?.wheelArrangement == extraWheelArrangement ? .checkmark : .none
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }
        case 1:
            let wheelArrangement = wheelArrangements[indexPath.row]
            cell.textLabel?.text = wheelArrangement
            cell.accessoryType = model?.wheelArrangement == wheelArrangement ? .checkmark : .none
        default: preconditionFailure("Unexpected indexPath: \(indexPath)")
        }

        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var currentIndexPath: IndexPath
        switch model?.wheelArrangement {
        case nil: currentIndexPath = IndexPath(row: 0, section: 0)
        case let wheelArrangement?:
            if let row = wheelArrangements.firstIndex(of: wheelArrangement) {
                currentIndexPath = IndexPath(row: row, section: 1)
            } else {
                currentIndexPath = IndexPath(row: 1, section: 0)
            }
        }

        if let cell = tableView.cellForRow(at: currentIndexPath) {
            cell.accessoryType = .none
        }

        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0: model?.wheelArrangement = nil
            case 1: model?.wheelArrangement = extraWheelArrangement
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }
        case 1: model?.wheelArrangement = wheelArrangements[indexPath.row]
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
