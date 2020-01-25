//
//  ClassificationsTableViewController.swift
//  EngineShed
//
//  Created by Scott James Remnant on 9/17/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import UIKit
import CoreData

class ClassificationsTableViewController : UITableViewController {

    var persistentContainer: NSPersistentContainer?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Model.Classification.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "classification", for: indexPath) as! ClassificationTableViewCell
        cell.classification = Model.Classification.allCases[indexPath.row]
        return cell
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "models" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }

            let viewController = segue.destination as! ModelsTableViewController
            viewController.persistentContainer = persistentContainer
            viewController.classification = Model.Classification.allCases[indexPath.row]
        }
    }

}
