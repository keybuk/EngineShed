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
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
#if !targetEnvironment(simulator)
        // Subscribe to changes in CloudKit, enabling remote notifications.
        beginNetworkActivity()
        persistentContainer.cloudObserver.subscribeToChanges { error in
            self.endNetworkActivity()
        }

        // Register for remote notifications of changes to the iCloud database.
        application.registerForRemoteNotifications()

        // Fetch any changes since last start.
        beginNetworkActivity()
        persistentContainer.cloudObserver.fetchChanges { error in
            self.endNetworkActivity()
        }

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
                let viewController = masterNavigationController.topViewController as! ModelClassificationsViewController
                viewController.managedObjectContext = persistentContainer.viewContext
            }

            if let navigationController = tabBarController.viewControllers?[1] as? UINavigationController {
                let viewController = navigationController.topViewController as! TrainsViewController
                viewController.managedObjectContext = persistentContainer.viewContext
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
        self.saveContext()
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
            if let _ = error {
                completionHandler(.failed)
            } else {
                completionHandler(.newData)
            }
        }
    }

    // MARK: - Split view

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? ModelViewController else { return false }
        if topAsDetailController.model == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: PersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = PersistentContainer(name: "EngineShed")
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

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

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
            assert(self.networkActivityCalls > 0, "Mismatched endNetworkActivity")
            self.networkActivityCalls -= 1
            if self.networkActivityCalls == 0 {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }

}

