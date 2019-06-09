//
//  TrainHeaderCollectionReusableView.swift
//  EngineShed iOS
//
//  Created by Scott James Remnant on 7/23/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import UIKit

class TrainHeaderCollectionReusableView : UICollectionReusableView {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!

    var train: Train? {
        didSet {
            configureView()
        }
    }

    func configureView() {
        nameLabel.text = train?.name
        detailsLabel.text = train?.details
    }

}
