//
//  TrainMember+Image.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/18/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

extension TrainMember {

    public var image: ModelImage? {
        guard let originalImage = model?.image else { return nil }
        return isFlipped ? originalImage.withHorizontallyFlippedOrientation() : originalImage
    }

}
