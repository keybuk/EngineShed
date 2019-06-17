//
//  ModelLiveryPickerTableViewController.swift
//  EngineShed
//
//  Created by Scott James Remnant on 3/9/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

class ModelLiveryPickerTableViewController : UITableViewController {

    var model: Model? {
        didSet {
            // If the current model livery isn't in the suggestions, place it as an extra row
            // in the first section and keep it there.
            _liveries = nil
            if let livery = model?.livery,
                !liveries.contains(livery)
            {
                extraLivery = livery
            }
        }
    }

    var extraLivery: String?

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
        case 0: return 1 + (extraLivery != nil ? 1 : 0)
        case 1: return liveries.count
        default: preconditionFailure("Unexpected section: \(section)")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "modelLivery", for: indexPath)

        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "None"
                cell.accessoryType = (model?.livery?.isEmpty ?? true) ? .checkmark : .none
            case 1:
                cell.textLabel?.text = extraLivery
                cell.accessoryType = model?.livery == extraLivery ? .checkmark : .none
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }
        case 1:
            let livery = liveries[indexPath.row]
            cell.textLabel?.text = livery
            cell.accessoryType = model?.livery == livery ? .checkmark : .none
        default: preconditionFailure("Unexpected indexPath: \(indexPath)")
        }

        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var currentIndexPath: IndexPath
        switch model?.livery {
        case nil: currentIndexPath = IndexPath(row: 0, section: 0)
        case let livery?:
            if let row = liveries.firstIndex(of: livery) {
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
            case 0: model?.livery = nil
            case 1: model?.livery = extraLivery
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }
        case 1: model?.livery = liveries[indexPath.row]
        default: preconditionFailure("Unexpected indexPath: \(indexPath)")
        }

        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
    }

    var liveries: [String] {
        if let liveries = _liveries { return liveries }

        _liveries = model?.suggestionsForLivery()
        return _liveries ?? []
    }

    var _liveries: [String]? = nil

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
