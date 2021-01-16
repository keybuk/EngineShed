//
//  RecordsViewController.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/6/20.
//  Copyright © 2020 Scott James Remnant. All rights reserved.
//

import Cocoa
import CoreData

import Database

class RecordsViewController : NSViewController {

    static let sectionHeaderElementKind = "section-header-element-kind"

    enum Section {
        case main
    }

    @IBOutlet var collectionView: NSCollectionView!

    var persistentContainer: NSPersistentContainer!
    var dataSource: NSCollectionViewDiffableDataSource<String, Model>! = nil
    var currentSnapshot: NSDiffableDataSourceSnapshot<String, Model>?

    override func viewDidLoad() {
        super.viewDidLoad()

        persistentContainer = (NSApplication.shared.delegate! as! AppDelegate).persistentContainer

        let modelItemNib = NSNib(nibNamed: "ModelItem", bundle: nil)
        collectionView.register(modelItemNib, forItemWithIdentifier: ModelItem.reuseIdentifier)

        let recordHeaderNib = NSNib(nibNamed: "RecordHeaderView", bundle: nil)
        collectionView.register(recordHeaderNib,
                                forSupplementaryViewOfKind: Self.sectionHeaderElementKind,
                                withIdentifier: RecordHeaderView.reuseIdentifier)

        let decoderTypeItemNib = NSNib(nibNamed: "DecoderTypeItem", bundle: nil)
        collectionView.register(decoderTypeItemNib, forItemWithIdentifier: DecoderTypeItem.reuseIdentifier)

        collectionView.collectionViewLayout = createLayout()

        dataSource = NSCollectionViewDiffableDataSource(collectionView: collectionView) { (collectionView, indexPath, model) -> NSCollectionViewItem? in
            let item = collectionView.makeItem(withIdentifier: ModelItem.reuseIdentifier, for: indexPath) as! ModelItem

            item.imageView?.image = model.image
            item.numberTextField?.stringValue = model.number ?? ""
            item.numberTextField?.isHidden = model.number?.isEmpty ?? true
            item.nameTextField?.stringValue = model.name ?? ""
            item.nameTextField?.isHidden = model.name?.isEmpty ?? true

            return item
        }

        dataSource.supplementaryViewProvider = { [weak self] (collectionView, kind, indexPath) -> (NSView & NSCollectionViewElement)? in
            let item = collectionView.makeSupplementaryView(ofKind: kind, withIdentifier: RecordHeaderView.reuseIdentifier, for: indexPath) as! RecordHeaderView

            item.label?.stringValue = self?.currentSnapshot?.sectionIdentifiers[indexPath.section] ?? "Section"

            return item
        }
    }

    func createLayout() -> NSCollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(56)) // 51 for model, 59 for decoder
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])

        let section = NSCollectionLayoutSection(group: group)

        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(36))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: sectionHeaderSize,
            elementKind: Self.sectionHeaderElementKind,
            alignment: .topLeading)
        sectionHeader.pinToVisibleBounds = true
        section.boundarySupplementaryItems = [sectionHeader]

        let layout = NSCollectionViewCompositionalLayout(section: section)
        return layout
    }

    func showDecoderTypes() {
    }

    func show(classification: Model.Classification) {
        switch classification {
        case .locomotive:
            view.window?.title = "Locomotives"
        case .coach:
            view.window?.title = "Coaches"
        case .wagon:
            view.window?.title = "Wagons"
        case .multipleUnit:
            view.window?.title = "Multiple Units"
        case .departmental:
            view.window?.title = "Departmentals"
        case .noPrototype:
            view.window?.title = "No Prototype"
        case .accessory:
            view.window?.title = "Accessories"
        case .vehicle:
            view.window?.title = "Vehicles"
        }

        let fetchRequest = Model.fetchRequestForModels(classification: classification)
        showModels(fetchRequest: fetchRequest)
    }

    func show(search: String?) {
        view.window?.title = "Search Results"

        let fetchRequest = Model.fetchRequestForModels(matching: search)
        showModels(fetchRequest: fetchRequest)
    }

    func showModels(fetchRequest: NSFetchRequest<Model>) {
        persistentContainer.viewContext.performAndWait {
            let models = try! fetchRequest.execute()

            var snapshot = NSDiffableDataSourceSnapshot<String, Model>()

            var lastClass: String?
            for model in models {
                if model.modelClass != lastClass {
                    let modelClass = model.modelClass ?? ""
                    snapshot.appendSections([modelClass])
                    lastClass = modelClass
                }

                snapshot.appendItems([model])
            }

            currentSnapshot = snapshot
            dataSource.apply(snapshot, animatingDifferences: false)

            view.window?.subtitle = "\(models.count) Model\(models.count == 1 ? "" : "s")"

            if models.count > 0 {
                collectionView.selectItems(at: [IndexPath(item: 0, section: 0)], scrollPosition: .centeredVertically)
                recordController?.currentRecord = .model(models[0])
            }
        }
    }

}

extension RecordsViewController: NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else { return }
        guard let model = dataSource.itemIdentifier(for: indexPath) else { return }

        recordController?.currentRecord = .model(model)
    }
}
