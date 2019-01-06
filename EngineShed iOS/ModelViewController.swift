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
        tableView.register(UINib(nibName: "DCCHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "dccHeaderView")
        tableView.register(UINib(nibName: "DetailsHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "detailsHeaderView")
        tableView.register(UINib(nibName: "MaintenanceHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "maintenanceHeaderView")
        tableView.register(UINib(nibName: "NotesHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "notesHeaderView")
    }

    func configureView() {

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 10
        case 1: return 2
        case 2: return 12
        case 3: return 5
        case 4: return 3
        case 5: return 1
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
        // DCC
        case (2, 0): identifier = "modelSocketCell"
        case (2, 1): identifier = "modelDecoderTypeCell"
        case (2, 2): identifier = "modelDecoderSerialNumberCell"
        case (2, 3): identifier = "modelDecoderFirmwareVersionCell"
        case (2, 4): identifier = "modelDecoderFirmwareDateCell"
        case (2, 5): identifier = "modelDecoderAddressCell"
        case (2, 6): identifier = "modelDecoderSoundAuthorCell"
        case (2, 7): identifier = "modelDecoderSoundProjectCell"
        case (2, 8): identifier = "modelDecoderSoundProjectVersionCell"
        case (2, 9): identifier = "modelDecoderSoundSettingsCell"
        case (2, 10): identifier = "modelSpeakerCell"
        case (2, 11): identifier = "modelSpeakerFittingsCell"
        // Details
        case (3, 0): identifier = "modelCouplingsCell"
        case (3, 1): identifier = "modelFeaturesCell"
        case (3, 2): identifier = "modelDetailPartsCell"
        case (3, 3): identifier = "modelFittedDetailPartsCell"
        case (3, 4): identifier = "modelModificationsCell"
        // Maintenance
        case (4, 0): identifier = "modelLastRunCell"
        case (4, 1): identifier = "modelLastOilCell"
        case (4, 2): identifier = "modelTasksCell"
        // Notes
        case (5, 0): identifier = "modelNotesCell"

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
        case 2: identifier = "dccHeaderView"
        case 3: identifier = "detailsHeaderView"
        case 4: identifier = "maintenanceHeaderView"
        case 5: identifier = "notesHeaderView"
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
