//
//  ModelSocketPickerTableViewController.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 3/9/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

import Database

class ModelSocketPickerTableViewController : UITableViewController {

    var model: Model? {
        didSet {
            // If the current model socket isn't in the suggestions, place it as an extra row
            // in the first section and keep it there.
            _sockets = nil
            if let socket = model?.socket,
                !sockets.contains(socket)
            {
                extraSocket = socket
            }

            // Update the view.
            tableView.reloadData()
        }
    }

    var extraSocket: String?

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
        case 0: return 1 + (extraSocket != nil ? 1 : 0)
        case 1: return sockets.count
        default: preconditionFailure("Unexpected section: \(section)")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "modelSocket", for: indexPath)

        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "None"
                cell.accessoryType = (model?.socket?.isEmpty ?? true) ? .checkmark : .none
            case 1:
                cell.textLabel?.text = extraSocket
                cell.accessoryType = model?.socket == extraSocket ? .checkmark : .none
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }
        case 1:
            let socket = sockets[indexPath.row]
            cell.textLabel?.text = socket
            cell.accessoryType = model?.socket == socket ? .checkmark : .none
        default: preconditionFailure("Unexpected indexPath: \(indexPath)")
        }

        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var currentIndexPath: IndexPath
        switch model?.socket {
        case nil: currentIndexPath = IndexPath(row: 0, section: 0)
        case let socket?:
            if let row = sockets.firstIndex(of: socket) {
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
            case 0: model?.socket = nil
            case 1: model?.socket = extraSocket
            default: preconditionFailure("Unexpected indexPath: \(indexPath)")
            }
        case 1: model?.socket = sockets[indexPath.row]
        default: preconditionFailure("Unexpected indexPath: \(indexPath)")
        }

        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
    }

    var sockets: [String] {
        if let sockets = _sockets { return sockets }

        _sockets = model?.suggestionsForSocket()
        return _sockets ?? []
    }

    var _sockets: [String]? = nil

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */

}
