//
//  Model+Image.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/17/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import Foundation

extension Model {

    #if os(iOS)
    public var image: UIImage? {
        get {
            return imageData.flatMap { UIImage(data: $0) }
        }

        set {
            imageData = newValue?.pngData()
        }
    }
    #elseif os(macOS)
    public var image: NSImage? {
        get {
            return imageData.flatMap { NSImage(data: $0) }
        }

        set {
            imageData = newValue?.pngData()
        }
    }
    #endif

}
