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

    var userInitiatedMove: (source: IndexPath, destination: IndexPath)?

    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        precondition(sourceIndexPath.section == destinationIndexPath.section, "Train members can't move between trains")

        let trainMember = fetchedResultsController.object(at: sourceIndexPath)
        guard let train = trainMember.train else { preconditionFailure("Train member without a train") }

        print("\(sourceIndexPath) -> \(destinationIndexPath)")
        train.removeFromMembers(at: sourceIndexPath.item)
        train.insertIntoMembers(trainMember, at: destinationIndexPath.item)

        do {
            userInitiatedMove = (sourceIndexPath, destinationIndexPath)
            try managedObjectContext?.save()
        } catch {
            fatalError("Save failed")
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
            else { fatalError("Cannot construct controller without fetchRequest and context") }
        
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

    var changeBlocks: [(UICollectionView) ->Void]? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        changeBlocks = []
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
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
        switch type {
        case .insert:
            changeBlocks!.append { $0.insertItems(at: [newIndexPath!]) }
        case .delete:
            changeBlocks!.append { $0.deleteItems(at: [indexPath!]) }
        case .update:
            changeBlocks!.append { $0.reloadItems(at: [indexPath!]) }
        case .move:
            if userInitiatedMove?.source != indexPath || userInitiatedMove?.destination != newIndexPath {
                changeBlocks!.append { $0.moveItem(at: indexPath!, to: newIndexPath!) }
            } else {
                print("Ignored move!")
                userInitiatedMove = nil
            }
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates({
            for changeBlock in changeBlocks! {
                changeBlock(collectionView)
            }
        })

        changeBlocks = nil
    }

}
