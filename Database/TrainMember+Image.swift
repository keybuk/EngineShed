//
//  TrainMember+Image.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/18/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

extension TrainMember {

    #if os(iOS)
    public var image: UIImage? {
        return model?.image.map {
            isFlipped ? $0.withHorizontallyFlippedOrientation() : $0
        }
    }
    #elseif os(macOS)
    public var image: NSImage? {
        return model?.image.map {
            isFlipped ? $0.withHorizontallyFlippedOrientation() : $0
        }
    }
    #endif

}
