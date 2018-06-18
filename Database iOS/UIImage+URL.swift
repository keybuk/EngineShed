//
//  UIImage+URL.swift
//  Database iOS
//
//  Created by Scott James Remnant on 6/17/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import Foundation
import UIKit

internal extension UIImage {

    convenience init?(contentsOf url: URL) {
        guard let data = try? Data(contentsOf: url) else { return nil }
        self.init(data: data)
    }

}

typealias ModelImage = UIImage
