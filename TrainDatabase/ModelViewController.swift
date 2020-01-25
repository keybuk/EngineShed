//
//  ModelViewController.swift
//  TrainDatabase
//
//  Created by Scott James Remnant on 12/16/17.
//  Copyright © 2017 Scott James Remnant. All rights reserved.
//

import Cocoa

extension NSStoryboard.SceneIdentifier {
    
    static let pickerViewController = "pickerViewController"
}

extension NSUserInterfaceItemIdentifier {
    
    static let trainMemberItem = NSUserInterfaceItemIdentifier("trainMemberItem")
    
}

extension NSPasteboard.PasteboardType {
    
    static let trainMemberItem = NSPasteboard.PasteboardType("com.netsplit.TrainDatabase.TrainMember")
    
}

class ModelViewController: NSViewController {
    
    @IBOutlet var scrollView: NSScrollView!
    
    @IBOutlet var imageView: NSImageView!
    @IBOutlet var classificationComboBox: NSComboBox!
    @IBOutlet var modelClassTextField: NSTextField!
    @IBOutlet var numberTextField: NSTextField!
    @IBOutlet var nameTextField: NSTextField!
    @IBOutlet var liveryComboBox: NSComboBox!
    @IBOutlet var detailsTextField: NSTextField!
    @IBOutlet var eraComboBox: NSComboBox!
    @IBOutlet var dispositionComboBox: NSComboBox!
    @IBOutlet var trainComboBox: NSComboBox!
    @IBOutlet var trainMemberCollectionView: NSCollectionView!
    @IBOutlet var motorComboBox: NSComboBox!
    @IBOutlet var lightingTokenField: NSTokenField!
    @IBOutlet var socketComboBox: NSComboBox!
    @IBOutlet var decoderTypeComboBox: NSComboBox!
    @IBOutlet var decoderSerialNumberComboBox: NSComboBox!
    @IBOutlet var decoderFirmwareVersionComboBox: NSComboBox!
    @IBOutlet var decoderFirmwareDateTextField: NSTextField!
    @IBOutlet var decoderAddressTextField: NSTextField!
    @IBOutlet var decoderSoundAuthorComboBox: NSComboBox!
    @IBOutlet var decoderSoundFileTextField: NSTextField!
    @IBOutlet var speakerComboBox: NSComboBox!
    @IBOutlet var speakerFittingTokenField: NSTokenField!
    @IBOutlet var couplingsTokenField: NSTokenField!
    @IBOutlet var featuresTokenField: NSTokenField!
    @IBOutlet var detailPartsTokenField: NSTokenField!
    @IBOutlet var modificationsTokenField: NSTokenField!
    @IBOutlet var lastRunTextField: NSTextField!
    @IBOutlet var lastOilTextField: NSTextField!
    @IBOutlet var tasksTokenField: NSTokenField!
    @IBOutlet var notesTextField: NSTextField!
    
    var classificationComboBoxDataSource: EnumComboBoxDataSource?
    var liveryComboBoxDataSource: SimpleComboBoxDataSource?
    var eraComboBoxDataSource: EnumComboBoxDataSource?
    var dispositionComboBoxDataSource: EnumComboBoxDataSource?
    var trainComboBoxController: ModelTrainComboBoxController?
    var motorComboBoxDataSource: SimpleComboBoxDataSource?
    var lightingTokenFieldDelegate: SimpleTokenFieldDelegate?
    var socketComboBoxDataSource: SimpleComboBoxDataSource?
    var decoderTypeComboBoxController: DecoderTypeComboBoxController?
    var decoderSerialNumberComboBoxController: DecoderSerialNumberComboBoxController?
    var decoderFirmwareVersionComboBoxDataSource: SimpleComboBoxDataSource?
    var decoderSoundAuthorComboBoxDataSource: SimpleComboBoxDataSource?
    var speakerComboBoxDataSource: SimpleComboBoxDataSource?
    var speakerFittingTokenFieldDelegate: SimpleTokenFieldDelegate?
    var couplingsTokenFieldDelegate: SimpleTokenFieldDelegate?
    var featuresTokenFieldDelegate: SimpleTokenFieldDelegate?
    var detailPartsTokenFieldDelegate: DetailPartsTokenFieldDelegate?
    var modificationsTokenFieldDelegate: SimpleTokenFieldDelegate?
    var tasksTokenFieldDelegate: SimpleTokenFieldDelegate?
    
    var model: Model!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        (decoderFirmwareDateTextField.formatter as? DateFormatter)?.timeZone = TimeZone(secondsFromGMT: 0)
        (lastRunTextField.formatter as? DateFormatter)?.timeZone = TimeZone(secondsFromGMT: 0)
        (lastOilTextField.formatter as? DateFormatter)?.timeZone = TimeZone(secondsFromGMT: 0)

        trainMemberCollectionView.register(TrainMemberItem.self, forItemWithIdentifier: .trainMemberItem)
        trainMemberCollectionView.registerForDraggedTypes([ .trainMemberItem ])
    }
 
    override func viewDidAppear() {
        super.viewDidAppear()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(currentRecordChanged), name: .currentRecordChanged, object: view.window)
        
        updateCurrentRecord()
        scrollToTop()
    }
    
    func scrollToTop() {
        // This is a total hack, but I've no idea how to fix it.
        scrollView.documentView?.frame.origin.y = 0
        let y = NSMaxY(scrollView.documentView?.frame ?? .zero) - NSHeight(scrollView.contentView.bounds)
        scrollView.scroll(CGPoint(x: 0.0, y: y))
    }
    
    @objc
    func currentRecordChanged(_ notification: Notification) {
        DispatchQueue.main.async {
            self.updateCurrentRecord()
        }
    }
    
    func updateCurrentRecord() {
        guard let currentRecord = recordController?.currentRecord else { return }
        guard case .model(let model) = currentRecord else { return }

        self.model = model
        
        reloadData()
    }
    
    func reloadData() {
        imageView.image = model.image
        
        classificationComboBoxDataSource = EnumComboBoxDataSource(wrapping: Model.Classification.self)
        classificationComboBox.dataSource = classificationComboBoxDataSource
        classificationComboBox.formatter = classificationComboBoxDataSource
        classificationComboBox.objectValue = model.classification.map(NSArray.init(object:))
        
        modelClassTextField.stringValue = model.modelClass
        numberTextField.stringValue = model.number
        nameTextField.stringValue = model.name
        
        liveryComboBoxDataSource = try? SimpleComboBoxDataSource(using: model.sortedValuesForLivery)
        liveryComboBox.dataSource = liveryComboBoxDataSource
        liveryComboBox.stringValue = model.livery
        
        detailsTextField.stringValue = model.details
        
        eraComboBoxDataSource = EnumComboBoxDataSource(wrapping: Model.Era.self)
        eraComboBox.dataSource = eraComboBoxDataSource
        eraComboBox.formatter = eraComboBoxDataSource
        eraComboBox.objectValue = model.era.map(NSArray.init(object:))
        
        dispositionComboBoxDataSource = EnumComboBoxDataSource(wrapping: Model.Disposition.self)
        dispositionComboBox.dataSource = dispositionComboBoxDataSource
        dispositionComboBox.formatter = dispositionComboBoxDataSource
        dispositionComboBox.objectValue = model.disposition.map(NSArray.init(object:))

        trainComboBoxController = try? ModelTrainComboBoxController(model: model)
        trainComboBox.dataSource = trainComboBoxController
        trainComboBox.formatter = trainComboBoxController
        trainComboBox.stringValue = model.trainMember?.train.name ?? ""
        
        trainMemberCollectionView.reloadData()

        motorComboBoxDataSource = try? SimpleComboBoxDataSource(using: model.sortedValuesForMotor)
        motorComboBox.dataSource = motorComboBoxDataSource
        motorComboBox.stringValue = model.motor
        
        lightingTokenFieldDelegate = SimpleTokenFieldDelegate(using: model.sortedValuesForLighting(startingWith:))
        lightingTokenField.delegate = lightingTokenFieldDelegate
        lightingTokenField.objectValue = model.lighting.sorted()

        socketComboBoxDataSource = try? SimpleComboBoxDataSource(using: model.sortedValuesForSocket)
        socketComboBox.dataSource = socketComboBoxDataSource
        socketComboBox.stringValue = model.socket
        
        reloadDecoderFields()

        speakerComboBoxDataSource = try? SimpleComboBoxDataSource(using: model.sortedValuesForSpeaker)
        speakerComboBox.dataSource = speakerComboBoxDataSource
        speakerComboBox.stringValue = model.speaker
        
        speakerFittingTokenFieldDelegate = SimpleTokenFieldDelegate(using: model.sortedValuesForSpeakerFitting(startingWith:))
        speakerFittingTokenField.delegate = speakerFittingTokenFieldDelegate
        speakerFittingTokenField.objectValue = model.speakerFitting.sorted()

        couplingsTokenFieldDelegate = SimpleTokenFieldDelegate(using: model.sortedValuesForCouplings(startingWith:))
        couplingsTokenField.delegate = couplingsTokenFieldDelegate
        couplingsTokenField.objectValue = model.couplings.sorted()
        
        featuresTokenFieldDelegate = SimpleTokenFieldDelegate(using: model.sortedValuesForFeatures(startingWith:))
        featuresTokenField.delegate = featuresTokenFieldDelegate
        featuresTokenField.objectValue = model.features.sorted()
        
        detailPartsTokenFieldDelegate = DetailPartsTokenFieldDelegate(model: model)
        detailPartsTokenField.delegate = detailPartsTokenFieldDelegate
        detailPartsTokenField.objectValue = nil
        detailPartsTokenField.objectValue = model.detailParts.sorted()
        
        modificationsTokenFieldDelegate = SimpleTokenFieldDelegate(using: model.sortedValuesForModifications(startingWith:))
        modificationsTokenField.delegate = modificationsTokenFieldDelegate
        modificationsTokenField.objectValue = model.modifications.sorted()

        lastRunTextField.objectValue = model.lastRun
        lastOilTextField.objectValue = model.lastOil
        
        tasksTokenFieldDelegate = SimpleTokenFieldDelegate(using: model.sortedValuesForTasks(startingWith:))
        tasksTokenField.delegate = tasksTokenFieldDelegate
        tasksTokenField.objectValue = model.tasks.sorted()

        notesTextField.stringValue = model.notes
    }
    
    func reloadDecoderFields() {
        decoderTypeComboBoxController = try? DecoderTypeComboBoxController(model: model)
        decoderTypeComboBox.dataSource = decoderTypeComboBoxController
        decoderTypeComboBox.formatter = decoderTypeComboBoxController
        decoderTypeComboBox.objectValue = model.decoder?.type.map(NSArray.init(object:))
    
        decoderSerialNumberComboBoxController = try? DecoderSerialNumberComboBoxController(model: model)
        decoderSerialNumberComboBox.dataSource = decoderSerialNumberComboBoxController
        decoderSerialNumberComboBox.formatter = decoderSerialNumberComboBoxController
        decoderSerialNumberComboBox.stringValue = model.decoder?.serialNumber ?? ""

        decoderFirmwareVersionComboBoxDataSource = model.decoder.flatMap({ try? SimpleComboBoxDataSource(using: $0.sortedValuesForFirmwareVersion) })
        decoderFirmwareVersionComboBox.dataSource = decoderFirmwareVersionComboBoxDataSource
        decoderFirmwareVersionComboBox.stringValue = model.decoder?.firmwareVersion ?? ""

        decoderFirmwareDateTextField.objectValue = model.decoder?.firmwareDate
        decoderAddressTextField.objectValue = model.decoder?.address != 0 ? model.decoder?.address : nil

        decoderSoundAuthorComboBoxDataSource = model.decoder.flatMap({ try? SimpleComboBoxDataSource(using: $0.sortedValuesForSoundAuthor) })
        decoderSoundAuthorComboBox.dataSource = decoderSoundAuthorComboBoxDataSource
        decoderSoundAuthorComboBox.stringValue = model.decoder?.soundAuthor ?? ""
        
        decoderSoundFileTextField.stringValue = model.decoder?.soundFile ?? ""
    }
    
    func fillFromSimilar() {
        if (try? model.fillFromSimilar()) == true {
            reloadData()
        }
    }
    
    @IBAction func imageChanged(_ sender: NSImageView) {
        model.image = sender.image
    }
    
    @IBAction func classificationChanged(_ sender: NSComboBox) {
        let classification = (sender.objectValue as? [Model.Classification])?.first
        let tryFill = model.classification != classification
        model.classification = classification
        
        if tryFill {
            fillFromSimilar()
        }
    }
    
    @IBAction func modelClassChanged(_ sender: NSTextField) {
        let modelClass = sender.stringValue
        let tryFill = model.modelClass != modelClass
        model.modelClass = modelClass
        
        if tryFill {
            fillFromSimilar()
        }
    }
    
    @IBAction func numberChanged(_ sender: NSTextField) {
        model.number = sender.stringValue
    }
    
    @IBAction func nameChanged(_ sender: NSTextField) {
        model.name = sender.stringValue
    }

    @IBAction func liveryChanged(_ sender: NSTextField) {
        model.livery = sender.stringValue
    }

    @IBAction func detailsChanged(_ sender: NSTextField) {
        model.details = sender.stringValue
    }

    @IBAction func eraChanged(_ sender: NSComboBox) {
        model.era = (sender.objectValue as? [Model.Era])?.first
    }
    
    @IBAction func dispositionChanged(_ sender: NSComboBox) {
        model.disposition = (sender.objectValue as? [Model.Disposition])?.first
    }

    @IBAction func trainChanged(_ sender: NSComboBox) {
        if let train = (sender.objectValue as? [Train])?.first {
            guard train != model.trainMember?.train else { return }
            
            // Before changing the train, detach the existing member record, and discard if necessary.
            if let trainMember = model.trainMember {
                model.trainMember = nil
                trainMember.deleteIfUnused()
            }
            
            model.createTrainMember(in: train)
        } else if let trainMember = model.trainMember, trainMember.train.members.count == 1 {
            // Rename the existing train.
            var train = trainMember.train
            train.name = sender.stringValue
        } else {
            // Before creating a new train, detach the existing member record, and discard if necessary.
            if let trainMember = model.trainMember {
                let train = trainMember.train
                model.trainMember = nil
                trainMember.deleteIfUnused()
                train.deleteIfUnused()
            }

            if !sender.stringValue.isEmpty {
                model.createTrain(named: sender.stringValue)
            }
        }
        
        trainMemberCollectionView.reloadData()
    }
    
    @IBAction func motorChanged(_ sender: NSTextField) {
        model.motor = sender.stringValue
    }
    
    @IBAction func lightingShowPicker(_ sender: NSButton) {
        guard let pickerViewController = storyboard?.instantiateController(withIdentifier: .pickerViewController) as? PickerViewController else { return }
        pickerViewController.pick(for: lightingTokenField, from: try! model.sortedValuesForLighting(), setValues: model.lighting) {
            self.model.lighting = $0
            self.lightingTokenField.objectValue = self.model.lighting.sorted()
        }
    }
    
    @IBAction func lightingChanged(_ sender: NSTokenField) {
        model.lighting = Set(sender.objectValue as! [String])
    }
    
    @IBAction func socketChanged(_ sender: NSTextField) {
        model.socket = sender.stringValue
     
        reloadDecoderFields()
    }
    
    @IBAction func decoderTypeChanged(_ sender: NSComboBox) {
        let decoderType = (sender.objectValue as? [DecoderType])?.first
        if decoderType != nil { model.createDecoderIfNeeded() }
        model.decoder?.type = decoderType
        
        reloadDecoderFields()
    }
    
    @IBAction func decoderSerialNumberChanged(_ sender: NSComboBox) {
        if let decoder = (sender.objectValue as? [Decoder])?.first {
            let oldDecoder = model.decoder
            model.decoder = decoder
            if oldDecoder != decoder { oldDecoder?.deleteIfUnused() }
        } else {
            // If there is already a decoder attached, and that decoder has a serial number, we actually don't want to change the serial number of the existing decoder and probably want a new record.
            if let oldDecoder = model.decoder, !oldDecoder.serialNumber.isEmpty {
                model.decoder = nil
                oldDecoder.deleteIfUnused()
            }
            
            let serialNumber = sender.stringValue
            if !serialNumber.isEmpty { model.createDecoderIfNeeded() }
            model.decoder?.serialNumber = serialNumber
        }

        reloadDecoderFields()
    }
    
    @IBAction func decoderFirmwareVersionChanged(_ sender: NSComboBox) {
        let firmwareVersion = sender.stringValue
        if !firmwareVersion.isEmpty { model.createDecoderIfNeeded() }
        model.decoder?.firmwareVersion = firmwareVersion
        
        if !firmwareVersion.isEmpty {
            if let firmwareDate = try! model.decoder?.firmwareDate(for: firmwareVersion) {
                model.decoder?.firmwareDate = firmwareDate
                decoderFirmwareDateTextField.objectValue = firmwareDate
            }
        }
        
        model.decoder?.deleteIfEmpty()
    }
    
    @IBAction func decoderFirmwareDateChanged(_ sender: NSTextField) {
        let firmwareDate = sender.objectValue as? Date
        if firmwareDate != nil { model.createDecoderIfNeeded() }
        model.decoder?.firmwareDate = firmwareDate
        
        model.decoder?.deleteIfEmpty()
    }

    @IBAction func decoderAddressChanged(_ sender: NSTextField) {
        let address = sender.objectValue != nil ? sender.integerValue : 0
        if address != 0 { model.createDecoderIfNeeded() }
        model.decoder?.address = address
        
        model.decoder?.deleteIfEmpty()
    }

    @IBAction func decoderSoundAuthorChanged(_ sender: NSTextField) {
        let soundAuthor = sender.stringValue
        if !soundAuthor.isEmpty { model.createDecoderIfNeeded() }
        model.decoder?.soundAuthor = soundAuthor
        
        model.decoder?.deleteIfEmpty()
    }
    
    @IBAction func decoderSoundFileChanged(_ sender: NSTextField) {
        let soundFile = sender.stringValue
        if !soundFile.isEmpty { model.createDecoderIfNeeded() }
        model.decoder?.soundFile = soundFile
        
        model.decoder?.deleteIfEmpty()
    }

    @IBAction func speakerChanged(_ sender: NSTextField) {
        model.speaker = sender.stringValue
    }
    
    @IBAction func speakerFittingShowPicker(_ sender: NSButton) {
        guard let pickerViewController = storyboard?.instantiateController(withIdentifier: .pickerViewController) as? PickerViewController else { return }
        pickerViewController.pick(for: speakerFittingTokenField, from: try! model.sortedValuesForSpeakerFitting(), setValues: model.speakerFitting) {
            self.model.speakerFitting = $0
            self.speakerFittingTokenField.objectValue = self.model.speakerFitting.sorted()
        }
    }

    @IBAction func speakerFittingChanged(_ sender: NSTokenField) {
        model.speakerFitting = Set(sender.objectValue as! [String])
    }
    
    @IBAction func couplingsShowPicker(_ sender: NSButton) {
        guard let pickerViewController = storyboard?.instantiateController(withIdentifier: .pickerViewController) as? PickerViewController else { return }
        pickerViewController.pick(for: couplingsTokenField, from: try! model.sortedValuesForCouplings(), setValues: model.couplings) {
            self.model.couplings = $0
            self.couplingsTokenField.objectValue = self.model.couplings.sorted()
        }
    }

    @IBAction func couplingsChanged(_ sender: NSTokenField) {
        model.couplings = Set(sender.objectValue as! [String])
    }
    
    @IBAction func featuresShowPicker(_ sender: NSButton) {
        guard let pickerViewController = storyboard?.instantiateController(withIdentifier: .pickerViewController) as? PickerViewController else { return }
        pickerViewController.pick(for: featuresTokenField, from: try! model.sortedValuesForFeatures(), setValues: model.features) {
            self.model.features = $0
            self.featuresTokenField.objectValue = self.model.features.sorted()
        }
    }

    @IBAction func featuresChanged(_ sender: NSTokenField) {
        model.features = Set(sender.objectValue as! [String])
    }

    @IBAction func detailPartsShowPicker(_ sender: NSButton) {
        // FIXME: this is really hacky
        let detailPartNames = Set(model.detailParts.map({ $0.title }))
        
        guard let pickerViewController = storyboard?.instantiateController(withIdentifier: .pickerViewController) as? PickerViewController else { return }
        pickerViewController.pick(for: detailPartsTokenField, from: try! model.sortedValuesForDetailParts(), setValues: detailPartNames) { newDetailPartNames in
            let newDetailParts = Set(newDetailPartNames.map({ Model.DetailPart(title: $0, isFitted: false) }))
            self.model.detailParts = self.model.detailParts.intersection(newDetailParts).union(newDetailParts)
            
            self.detailPartsTokenField.objectValue = nil
            self.detailPartsTokenField.objectValue = self.model.detailParts.sorted()
        }

    }
    
    @IBAction func detailPartsChanged(_ sender: NSTokenField) {
        model.detailParts = Set(sender.objectValue as! [Model.DetailPart])
    }

    @IBAction func modificationsShowPicker(_ sender: NSButton) {
        guard let pickerViewController = storyboard?.instantiateController(withIdentifier: .pickerViewController) as? PickerViewController else { return }
        pickerViewController.pick(for: modificationsTokenField, from: try! model.sortedValuesForModifications(), setValues: model.modifications) {
            self.model.modifications = $0
            self.modificationsTokenField.objectValue = self.model.modifications.sorted()
        }
    }

    @IBAction func modificationsChanged(_ sender: NSTokenField) {
        model.modifications = Set(sender.objectValue as! [String])
    }
    
    @IBAction func lastRunChanged(_ sender: NSTextField) {
        model.lastRun = sender.objectValue as? Date
    }

    @IBAction func lastOilChanged(_ sender: NSTextField) {
        model.lastOil = sender.objectValue as? Date
    }

    @IBAction func tasksShowPicker(_ sender: NSButton) {
        guard let pickerViewController = storyboard?.instantiateController(withIdentifier: .pickerViewController) as? PickerViewController else { return }
        pickerViewController.pick(for: tasksTokenField, from: try! model.sortedValuesForTasks(), setValues: model.tasks) {
            self.model.tasks = $0
            self.tasksTokenField.objectValue = self.model.tasks.sorted()
        }
    }

    @IBAction func tasksChanged(_ sender: NSTokenField) {
        model.tasks = Set(sender.objectValue as! [String])
    }
    
    @IBAction func notesChanged(_ sender: NSTextField) {
        model.notes = sender.stringValue
    }

}

extension ModelViewController : NSCollectionViewDataSource {
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let trainMember = model?.trainMember else { return 0 }
        
        return trainMember.train.members.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: .trainMemberItem, for: indexPath) as! TrainMemberItem
        guard let train = model.trainMember?.train else { return item }

        let trainMember = train.members[indexPath.item]
        item.trainMember = trainMember
        item.isCurrentItem = trainMember == model.trainMember
        
        return item
    }
    
}

extension ModelViewController : NSCollectionViewDelegate {
    
    func draggingIndexPath(collectionView: NSCollectionView, draggingInfo: NSDraggingInfo) -> IndexPath? {
        var oldItem: Int?
        draggingInfo.enumerateDraggingItems(options: [], for: collectionView, classes: [NSPasteboardItem.self], searchOptions: [:]) {
            (draggingItem, idx, stop) in
            guard let pasteboardItem = draggingItem.item as? NSPasteboardItem else { return }
            guard let itemStr = pasteboardItem.string(forType: .trainMemberItem) else { return }
            guard let item = Int(itemStr) else { return }
            
            oldItem = item
        }
        
        return oldItem.map({ IndexPath(item: $0, section: 0) })
    }
    
    func resetDragIndicators(collectionView: NSCollectionView) {
        for case let item as TrainMemberItem in collectionView.visibleItems() {
            item.dropAfterIndicator.isHidden = true
            item.dropBeforeIndicator.isHidden = true
            item.dropOnIndicator.isHidden = true
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt indexPath: IndexPath) -> NSPasteboardWriting? {
        let item = NSPasteboardItem()
        item.setString(String(indexPath.item), forType: .trainMemberItem)
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, validateDrop draggingInfo: NSDraggingInfo, proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionView.DropOperation>) -> NSDragOperation {
        resetDragIndicators(collectionView: collectionView)
        guard let train = model.trainMember?.train else { return [] }

        let indexPath = proposedDropIndexPath.pointee as IndexPath
        
        switch proposedDropOperation.pointee {
        case .on:
            guard let oldIndexPath = draggingIndexPath(collectionView: collectionView, draggingInfo: draggingInfo) else { return [] }
            guard let _ = train.members[oldIndexPath.item].model else { return [] }
            
            if let onItem = collectionView.item(at: indexPath) as? TrainMemberItem {
                onItem.dropOnIndicator.isHidden = false
            }
            return .move
        case .before:
            if let beforeItem = collectionView.item(at: indexPath) as? TrainMemberItem {
                beforeItem.dropBeforeIndicator.isHidden = false
            } else if indexPath.item > 0, let afterItem = collectionView.item(at: IndexPath(item: indexPath.item - 1, section: indexPath.section)) as? TrainMemberItem {
                afterItem.dropAfterIndicator.isHidden = false
            }
            return .move
        @unknown default:
            assertionFailure("Unknown drop operation: \(proposedDropOperation.pointee)")
            return []
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, indexPath: IndexPath, dropOperation: NSCollectionView.DropOperation) -> Bool {
        guard let oldIndexPath = draggingIndexPath(collectionView: collectionView, draggingInfo: draggingInfo) else { return false }
        guard var train = model.trainMember?.train else { return false }
        
        let oldMember = train.members[oldIndexPath.item]
        
        switch dropOperation {
        case .on:
            // Dropping on replaces the model, but leaves the old member.
            guard oldIndexPath.item != indexPath.item else { return false }
            train.members[indexPath.item].model = oldMember.model
            train.members[oldIndexPath.item].model = nil
            
            if train.members[oldIndexPath.item].deleteIfUnused() == true {
                collectionView.performBatchUpdates({
                    collectionView.deleteItems(at: Set([oldIndexPath]))
                    collectionView.reloadItems(at: Set([indexPath]))
                })
            } else {
                collectionView.reloadItems(at: Set([oldIndexPath, indexPath]))
            }
            
            return true
        case .before:
            // Dropping between members rearranges the train.
            if oldIndexPath.item < indexPath.item {
                train.members.remove(at: oldIndexPath.item)
                train.members.insert(oldMember, at: indexPath.item - 1)
                
                collectionView.moveItem(at: oldIndexPath, to: IndexPath(item: indexPath.item - 1, section: indexPath.section))
            } else {
                train.members.remove(at: oldIndexPath.item)
                train.members.insert(oldMember, at: indexPath.item)
                
                collectionView.moveItem(at: oldIndexPath, to: indexPath)
            }
            
            return true
        @unknown default:
            assertionFailure("Unknown drop operation: \(dropOperation)")
            return false
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, dragOperation operation: NSDragOperation) {
        resetDragIndicators(collectionView: collectionView)
    }
    
}

