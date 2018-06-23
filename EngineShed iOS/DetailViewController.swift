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

    @IBAction func addTest(_ sender: Any) {
        guard let managedObjectContext = managedObjectContext else { return }
        guard let detailParts = model?.detailParts as? Set<DetailPart> else { return }

        if let _ = detailParts.first(where: { $0.title == "Test" }) {
            print("Already test")
        } else {
            let detailPart = DetailPart(context: managedObjectContext)
            detailPart.title = "Test"

            model?.addToDetailParts(detailPart)
        }
    }

    @IBAction func removeTest(_ sender: Any) {
        guard let managedObjectContext = managedObjectContext else { return }
        guard let detailParts = model?.detailParts as? Set<DetailPart> else { return }
        guard let fittedDetailParts = model?.fittedDetailParts as? Set<FittedDetailPart> else { return }

        if let detailPart = detailParts.first(where: { $0.title == "Test" }) {
            model?.removeFromDetailParts(detailPart)
            managedObjectContext.delete(detailPart)
        } else {
            print("No test")
        }

        if let fittedDetailPart = fittedDetailParts.first(where: { $0.title == "Test" }) {
            model?.removeFromFittedDetailParts(fittedDetailPart)
            managedObjectContext.delete(fittedDetailPart)
        }
    }

    @IBAction func toggleTestFitted(_ sender: Any) {
        guard let managedObjectContext = managedObjectContext else { return }
        guard let detailParts = model?.detailParts as? Set<DetailPart> else { return }
        guard let fittedDetailParts = model?.fittedDetailParts as? Set<FittedDetailPart> else { return }

        if let fittedDetailPart = fittedDetailParts.first(where: { $0.title == "Test" }) {
            model?.removeFromFittedDetailParts(fittedDetailPart)
            managedObjectContext.delete(fittedDetailPart)
        } else if let _ = detailParts.first(where: { $0.title == "Test" }) {
            let fittedDetailPart = FittedDetailPart(context: managedObjectContext)
            fittedDetailPart.title = "Test"

            model?.addToFittedDetailParts(fittedDetailPart)
        } else {
            print("No test")
        }
    }

    @IBAction func updateField(_ sender: UIButton) {
        model?.notes = notesTextView?.text
    }

    @IBAction func saveChanges(_ sender: Any) {
        guard let managedObjectContext = managedObjectContext else { return }

        try! managedObjectContext.save()
    }

    @IBAction func copyModelButton(_ sender: Any) {
        guard let managedObjectContext = managedObjectContext else { return }

        let otherModel = Model(context: managedObjectContext)

        otherModel.purchase = model?.purchase
        otherModel.classificationRawValue = model?.classificationRawValue ?? 0
        otherModel.dispositionRawValue = model?.dispositionRawValue ?? 0
        otherModel.modelClass = model?.modelClass
        otherModel.number = model?.number.map { $0 + " (1)" }
        otherModel.name = model?.name
        otherModel.image = model?.image
    }

    @IBAction func deleteSelf(_ sender: Any) {
        guard let managedObjectContext = managedObjectContext else { return }

        managedObjectContext.delete(model!)
    }

}

