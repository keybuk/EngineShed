//
//  TrainsCollectionViewController.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 7/13/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import UIKit
import CoreData

class TrainsCollectionViewController : UICollectionViewController, NSFetchedResultsControllerDelegate {

    var persistentContainer: NSPersistentContainer?

    var fetchRequest: NSFetchRequest<TrainMember>?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        if fetchRequest == nil {
            fetchRequest = TrainMember.fetchRequestForTrains()
        }

        if let managedObjectContext = persistentContainer?.viewContext {
            let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: managedObjectContext)
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
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "trainHeader", for: indexPath) as! TrainHeaderCollectionReusableView
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(trainHeaderTapped))
        view.addGestureRecognizer(recognizer)

        let trainMember = fetchedResultsController.object(at: indexPath)
        view.train = trainMember.train
        return view
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trainMember", for: indexPath) as! TrainMemberCollectionViewCell
        let trainMember = fetchedResultsController.object(at: indexPath)
        cell.trainMember = trainMember
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        precondition(sourceIndexPath.section == destinationIndexPath.section, "Train members can't move between trains")

        let trainMember = fetchedResultsController.object(at: sourceIndexPath)
        guard let train = trainMember.train else { preconditionFailure("Train member without a train") }

        guard let managedObjectContext = persistentContainer?.newBackgroundContext() else { preconditionFailure("No database context") }
        do {
            try managedObjectContext.performAndWait {
                let train = managedObjectContext.object(with: train.objectID) as! Train
                let trainMember = managedObjectContext.object(with: trainMember.objectID) as! TrainMember

                train.removeFromMembers(at: sourceIndexPath.item)
                train.insertIntoMembers(trainMember, at: destinationIndexPath.item)

                self.changeIsUserDriven = true
                try managedObjectContext.save()
            }
        } catch {
            collectionView.moveItem(at: destinationIndexPath, to: sourceIndexPath)

            let alert = UIAlertController(title: "Unable to Save", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
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

        guard let managedObjectContext = persistentContainer?.viewContext, let fetchRequest = fetchRequest
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
        if changeIsUserDriven {
            changeIsUserDriven = false
            return
        }

        changeBlocks = []
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            changeBlocks?.append { $0.insertSections(IndexSet(integer: sectionIndex)) }
        case .delete:
            changeBlocks?.append { $0.deleteSections(IndexSet(integer: sectionIndex)) }
        default:
            assertionFailure("Unimplemented fetched results controller change type: \(type)")
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            changeBlocks?.append { $0.insertItems(at: [newIndexPath!]) }
        case .delete:
            changeBlocks?.append { $0.deleteItems(at: [indexPath!]) }
        case .update:
            changeBlocks?.append {
                // Don't use reloadItems since that's a delete and insertion.
                if let cell = $0.cellForItem(at: indexPath!) as? TrainMemberCollectionViewCell {
                    cell.trainMember = anObject as? TrainMember
                }
            }
        case .move:
            changeBlocks?.append {
                // Move implies an update;don't use reloadItems since that's a delete and insertion
                // already.
                if let cell = $0.cellForItem(at: indexPath!) as? TrainMemberCollectionViewCell {
                    cell.trainMember = anObject as? TrainMember
                }

                // Prefer moveItem to get an animation.
                $0.moveItem(at: indexPath!, to: newIndexPath!)
            }
        @unknown default:
            assertionFailure("Unimplemented fetched results controller change type: \(type)")
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let changeBlocks = changeBlocks else { return }
        if changeBlocks.isEmpty {
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

    // MARK: - Notifications

    @objc
    func managedObjectContextObjectsDidChange(_ notification: Notification) {
        dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
        guard let userInfo = notification.userInfo else { return }

        // We use Train objects as a header, but our fetch is for TrainMember so we don't get
        // notifications of changes just to Train objects themselves.
        //
        // Watch for the event where they are refreshed, by sync from cloud or merge after save
        // from other context, and update their headers accordingly.
        if let refreshedObjects = userInfo[NSRefreshedObjectsKey] as? Set<NSManagedObject> {
            for case let train as Train in refreshedObjects {
                guard let trainMember = train.members!.firstObject as? TrainMember else {
                    assertionFailure("Train without member")
                    continue
                }

                if let indexPath = fetchedResultsController.indexPath(forObject: trainMember) {
                    let kind = UICollectionView.elementKindSectionHeader
                    let headerIndexPath = IndexPath(row: 0, section: indexPath.section)
                    if let view = collectionView.supplementaryView(forElementKind: kind, at: headerIndexPath) as! TrainHeaderCollectionReusableView? {
                        view.train = train
                    }
                }
            }
        }
    }

    // MARK: - Navigation

    var tappedIndexPath: IndexPath?
    var addedTrain: Train?

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "train" {
            let train: Train
            if let indexPath = tappedIndexPath {
                tappedIndexPath = nil

                let trainMember = fetchedResultsController.object(at: indexPath)
                guard let trainMemberTrain = trainMember.train else { preconditionFailure("Train member without a train") }

                train = trainMemberTrain
            } else if let addedTrain = addedTrain {
                self.addedTrain = nil

                train = addedTrain
            } else { return }

            let viewController = segue.destination as! TrainTableViewController
            viewController.persistentContainer = persistentContainer
            viewController.train = train
        } else if segue.identifier == "trainAdd" {
            let navigationController = segue.destination as! UINavigationController

            let viewController = navigationController.topViewController as! TrainEditTableViewController
            viewController.persistentContainer = persistentContainer
            viewController.addTrain() { result in
                if case .saved(let train) = result {
                    self.addedTrain = train
                    //FIXME: select the header view once I've made that selectable
                    //self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
                    self.performSegue(withIdentifier: "train", sender: nil)
                }

                self.dismiss(animated: true)
            }
        }
    }

    @IBAction func trainHeaderTapped(_ sender: UITapGestureRecognizer) {
        let kind = UICollectionView.elementKindSectionHeader
        for indexPath in collectionView.indexPathsForVisibleSupplementaryElements(ofKind: kind) {
            if sender.view == collectionView.supplementaryView(forElementKind: kind, at: indexPath) {
                tappedIndexPath = indexPath
                performSegue(withIdentifier: "train", sender: sender.view)
            }
        }
    }

}
