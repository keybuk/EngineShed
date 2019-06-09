//
//  UINavigationController+PopDetail.swift
//  EngineShed
//
//  Created by Scott James Remnant on 3/7/19.
//  Copyright © 2019 Scott James Remnant. All rights reserved.
//

import UIKit

extension UINavigationController {

    /// Pops the top view controller from the navigation stack, or the navigation controller from
    /// a split view's stack, and updates the display.
    @discardableResult
    func popDetailViewController(animated: Bool) -> UIViewController? {
        // If we would be poppping the root view controller, and this navigation controller is the
        // top view controller of a navigation controller in the primary of a split view, pop this
        // navigation controller instead.
        if viewControllers.count == 1,
            let primaryNavigationController = splitViewController?.viewControllers.first as? UINavigationController,
            primaryNavigationController.topViewController == self
        {
            return primaryNavigationController.popViewController(animated: animated)
        } else {
            return popViewController(animated: animated)
        }
    }

}
