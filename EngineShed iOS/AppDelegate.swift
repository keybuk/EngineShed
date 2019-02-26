//
//  AppDelegate.swift
//  EngineShed
//
//  Created by Scott James Remnant on 6/15/18.
//  Copyright © 2018 Scott James Remnant. All rights reserved.
//

import UIKit
import CloudKit
import CoreData
import Dispatch

import Database

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate, CloudProviderDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
#if !targetEnvironment(simulator)
        // Subscribe to changes in CloudKit, enabling remote notifications.
        beginNetworkActivity()
        persistentContainer.cloudObserver.subscribeToChanges { error in
            self.endNetworkActivity()

            if let error = error {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "CloudKit Subscription Failed", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.window?.rootViewController?.present(alert, animated: true)
                }
            }
        }

        // Register for remote notifications of changes to the iCloud database.
        application.registerForRemoteNotifications()

        // Fetch any changes since last start.
        beginNetworkActivity()
        persistentContainer.cloudObserver.fetchChanges { error in
            self.endNetworkActivity()

            if let error = error {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Sync From CloudKit Failed", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.window?.rootViewController?.present(alert, animated: true)
                }
            }
        }

        persistentContainer.cloudProvider.delegate = self

        // Observe changes to our managed context, send to CloudKit.
        persistentContainer.cloudProvider.observeChanges()

        // Resume any long-lived operations from last run.
        persistentContainer.cloudProvider.resumeLongLivedOperations()
#endif

        if let tabBarController = window?.rootViewController as? UITabBarController {
            if let splitViewController = tabBarController.viewControllers?[0] as? UISplitViewController {
                let navigationController = splitViewController.viewControllers.last! as! UINavigationController
                navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
                splitViewController.delegate = self

                let masterNavigationController = splitViewController.viewControllers[0] as! UINavigationController
                let viewController = masterNavigationController.topViewController as! ClassificationsTableViewController
                viewController.persistentContainer = persistentContainer
            }

            if let splitViewController = tabBarController.viewControllers?[1] as? UISplitViewController {
                let navigationController = splitViewController.viewControllers.last! as! UINavigationController
                navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
                splitViewController.delegate = self

                let masterNavigationController = splitViewController.viewControllers[0] as! UINavigationController
                let viewController = masterNavigationController.topViewController as! PurchasesTableViewController
                viewController.persistentContainer = persistentContainer
            }

            if let navigationController = tabBarController.viewControllers?[2] as? UINavigationController {
                let viewController = navigationController.topViewController as! TrainsCollectionViewController
                viewController.persistentContainer = persistentContainer
            }
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }

    // MARK: - Remote notifications

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Remote notifications registered \(deviceToken)")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Registration failed \(error)")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Remote Notification")

        beginNetworkActivity()
        persistentContainer.cloudObserver.handleRemoteNotification(userInfo) { error in
            self.endNetworkActivity()
            if let error = error {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Sync From CloudKit Failed", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.window?.rootViewController?.present(alert, animated: true)
                }
                
                completionHandler(.failed)
            } else {
                completionHandler(.newData)
            }
        }
    }

    // MARK: - Cloud provider delegate

    func cloudProvider(_ cloudProvider: CloudProvider, didFailWithError error: Error) {
        let alert = UIAlertController(title: "Sync to CloudKit Failed", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        window?.rootViewController?.present(alert, animated: true)
    }

    // MARK: - Split view

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }

        // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        if let viewController = secondaryAsNavController.topViewController as? ModelTableViewController,
            viewController.model == nil { return true }
        if let viewController = secondaryAsNavController.topViewController as? PurchaseTableViewController,
            viewController.purchase == nil { return true }

        return false
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: LocalPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = LocalPersistentContainer.shared
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        // Merge changes from the store into the context automatically (e.g. CloudKit sync),
        // but keep any unsaved property values in this context.
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        return container
    }()

    // MARK: - Network activity indicator management

    var networkActivityCalls = 0

    func beginNetworkActivity() {
        DispatchQueue.main.async {
            self.networkActivityCalls += 1
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
    }

    func endNetworkActivity() {
        DispatchQueue.main.async {
            precondition(self.networkActivityCalls > 0, "Mismatched endNetworkActivity")
            self.networkActivityCalls -= 1
            if self.networkActivityCalls == 0 {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }

}

