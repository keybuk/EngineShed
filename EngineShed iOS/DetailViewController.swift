//
//  DetailViewController.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/15/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import UIKit
import CoreData

import Database

class DetailViewController: UIViewController {

    var managedObjectContext: NSManagedObjectContext?

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet var notesTextView: UITextView!

    func configureView() {
        // Update the user interface for the detail item.
        if let model = model {
            detailDescriptionLabel?.text = model.number ?? ""
            notesTextView?.text = model.notes ?? ""
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    var model: Model? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    @IBAction func saveChanges(_ sender: UIButton) {
        model?.notes = notesTextView?.text

        do {
            try managedObjectContext?.save()
        } catch {
            print("Attempt to save failed")
        }
    }

}

