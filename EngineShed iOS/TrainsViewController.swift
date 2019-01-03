//
//  TrainsViewController.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 7/13/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import UIKit
import CoreData

import Database

class TrainsViewController : UICollectionViewController, NSFetchedResultsControllerDelegate {

    var managedObjectContext: NSManagedObjectContext?

    var fetchRequest: NSFetchRequest<TrainMember>?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        if fetchRequest == nil {
            fetchRequest = TrainMember.fetchRequestForTrains()
        }

        if let managedObjectContext = managedObjectContext {
            let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange(notification:)), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: managedObjectContext)
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "trainHeaderView", for: indexPath) as! TrainHeaderView
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(trainHeaderTapped))
        view.addGestureRecognizer(recognizer)

        let trainMember = fetchedResultsController.object(at: indexPath)
        view.train = trainMember.train
        return view
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trainMemberCell", for: indexPath) as! TrainMemberCell
        let trainMember = fetchedResultsController.object(at: indexPath)
        cell.trainMember = trainMember
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        precondition(sourceIndexPath.section == destinationIndexPath.section, "Train members can't move between trains")

        let trainMember = fetchedResultsController.object(at: sourceIndexPath)
        guard let train = trainMember.train else { preconditionFailure("Train member without a train") }

        train.removeFromMembers(at: sourceIndexPath.item)
        train.insertIntoMembers(trainMember, at: destinationIndexPath.item)

        do {
            changeIsUserDriven = true
            try managedObjectContext?.save()
            changeIsUserDriven = false
        } catch {
            fatalError("Save failed \(error)")
        }
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

    override func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        return proposedIndexPath.section == originalIndexPath.section ? proposedIndexPath : originalIndexPath
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<TrainMember> {
        if let fetchedResultsController = _fetchedResultsController {
            return fetchedResultsController
        }

        guard let fetchRequest = fetchRequest, let managedObjectContext = managedObjectContext
            else { preconditionFailure("Cannot construct controller without fetchRequest and context") }
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: "train.name", cacheName: nil/*"TrainCollection.Train.Name"*/)
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }

        _fetchedResultsController = fetchedResultsController
        return fetchedResultsController
    }

    var _fetchedResultsController: NSFetchedResultsController<TrainMember>? = nil

    // MARK: NSFetchedResultsControllerDelegate

    /// Set to `true` across a context save to ignore any changes from it.
    var changeIsUserDriven = false

    /// Collated changes from a content change.
    var changeBlocks: [(UICollectionView) -> Void]? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard !changeIsUserDriven else { return }

        changeBlocks = []
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        guard !changeIsUserDriven else { return }

        switch type {
        case .insert:
            changeBlocks!.append { $0.insertSections(IndexSet(integer: sectionIndex)) }
        case .delete:
            changeBlocks!.append { $0.deleteSections(IndexSet(integer: sectionIndex)) }
        default:
            return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard !changeIsUserDriven else { return }

        switch type {
        case .insert:
            changeBlocks!.append { $0.insertItems(at: [newIndexPath!]) }
        case .delete:
            changeBlocks!.append { $0.deleteItems(at: [indexPath!]) }
        case .update:
            changeBlocks!.append {
                // Don't use reloadItems since that's a delete and insertion.
                if let cell = $0.cellForItem(at: indexPath!) as? TrainMemberCell {
                    cell.trainMember = anObject as? TrainMember
                }
            }
        case .move:
            changeBlocks!.append {
                // Move implies an update;don't use reloadItems since that's a delete and insertion
                // already.
                if let cell = $0.cellForItem(at: indexPath!) as? TrainMemberCell {
                    cell.trainMember = anObject as? TrainMember
                }

                // Prefer moveItem to get an animation.
                $0.moveItem(at: indexPath!, to: newIndexPath!)
            }
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let changeBlocks = changeBlocks else { return }
        guard !changeIsUserDriven && !changeBlocks.isEmpty else {
            self.changeBlocks = nil
            return
        }

        collectionView.performBatchUpdates({
            for changeBlock in changeBlocks {
                changeBlock(collectionView)
            }
        })

        self.changeBlocks = nil
    }

    @objc
    func managedObjectContextObjectsDidChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }

        // We use Train objects as a header, but our fetch is for TrainMember so we don't get
        // notifications of changes just to Train objects themselves.
        //
        // Watch for the event where they are refreshed, and update their headers accordingly.
        if let refreshedObjects = userInfo[NSRefreshedObjectsKey] as? Set<NSManagedObject> {
            for case let train as Train in refreshedObjects {
                guard let trainMember = train.members?.firstObject as? TrainMember else {
                    assertionFailure("Train without member")
                    continue
                }

                if let indexPath = fetchedResultsController.indexPath(forObject: trainMember) {
                    let kind = UICollectionView.elementKindSectionHeader
                    let headerIndexPath = IndexPath(row: 0, section: indexPath.section)
                    if let view = collectionView.supplementaryView(forElementKind: kind, at: headerIndexPath) as! TrainHeaderView? {
                        view.train = train
                    }
                }
            }
        }
    }

    // MARK: - Navigation

    var tappedIndexPath: IndexPath?

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "trainEdit" {
            guard let indexPath = tappedIndexPath else { return }

            let trainMember = fetchedResultsController.object(at: indexPath)
            guard let train = trainMember.train else { preconditionFailure("Train member without a train") }

            let viewController = segue.destination as! TrainEditViewController
            viewController.managedObjectContext = managedObjectContext
            viewController.train = train
        }
    }

    @IBAction func trainHeaderTapped(_ sender: UITapGestureRecognizer) {
        let kind = UICollectionView.elementKindSectionHeader
        for indexPath in collectionView.indexPathsForVisibleSupplementaryElements(ofKind: kind) {
            if sender.view == collectionView.supplementaryView(forElementKind: kind, at: indexPath) {
                tappedIndexPath = indexPath
                performSegue(withIdentifier: "trainEdit", sender: sender.view)
            }
        }
    }

}
