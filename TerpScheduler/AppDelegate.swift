//
//  AppDelegate.swift
//  TerpScheduler
//
//  Created by Ben Hall on 12/18/14.
//  Copyright (c) 2014 Tampa Preparatory School. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Override point for customization after application launch.
    let defaultValues = ["isDataInitialized": false, "isMiddleStudent":false, "shouldShadeStudyHall":true, "shouldShowExtraRow": true, "shouldNotifyWhen": "Evening"]
    NSUserDefaults.standardUserDefaults().registerDefaults(defaultValues)
    if let context = managedObjectContext{
      let files = ["schedule"]
      SemesterScheduleLoader(context: context, withJSONFiles: files)
    }
    if launchOptions?[UIApplicationLaunchOptionsLocalNotificationKey] == nil  && application.applicationIconBadgeNumber != 0{
      //application was launched from home screen with badge set, so clear the badge.
      //application.cancelAllLocalNotifications()
      application.applicationIconBadgeNumber = 0
    }
    
    let categories = setupNotification()
    let types: UIUserNotificationType = [UIUserNotificationType.Badge, UIUserNotificationType.Sound, UIUserNotificationType.Alert]
    application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: types, categories: categories))
    userColors = UserColors(defaults: userDefaults)
    return true
  }
  
  func setupNotification()->Set<NSObject>{
    let justInformAction = UIMutableUserNotificationAction()
    justInformAction.identifier = "justInform"
    justInformAction.title = "OK"
    justInformAction.activationMode = UIUserNotificationActivationMode.Foreground
    justInformAction.destructive = false
    justInformAction.authenticationRequired = true
    
    let ignoreAction = UIMutableUserNotificationAction()
    ignoreAction.identifier = "ignore"
    ignoreAction.title = "Ignore"
    ignoreAction.activationMode = UIUserNotificationActivationMode.Background
    ignoreAction.destructive = false
    ignoreAction.authenticationRequired = false
    
    let actionsArray = [justInformAction, ignoreAction]
    let category = UIMutableUserNotificationCategory()
    category.identifier = "taskReminderCategory"
    category.setActions(actionsArray, forContext: UIUserNotificationActionContext.Default)
    category.setActions(actionsArray, forContext: UIUserNotificationActionContext.Minimal)
    return Set<NSObject>(arrayLiteral: [category])
  }
  
  func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
    renumberBadge()
  }
  
  func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
    if identifier != "ignore" {
      application.cancelAllLocalNotifications()
      application.applicationIconBadgeNumber = 0
    } else {
      renumberBadge()
    }
    completionHandler()
  }
  
  lazy var userDefaults = UserDefaults()
  lazy var dataManager = DataManager()
  var userColors: UserColors?
  
  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    self.saveContext()
  }
  
  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
  }
  
  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //application.applicationIconBadgeNumber = 0
  }
  
  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    self.saveContext()
  }
  
  // MARK: - Core Data stack
  
  lazy var applicationDocumentsDirectory: NSURL = {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.tampaprep.TerpScheduler" in the application's documents Application Support directory.
    let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    return urls[urls.count-1] 
    }()
  
  lazy var managedObjectModel: NSManagedObjectModel = {
    // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
    let modelURL = NSBundle.mainBundle().URLForResource("TerpScheduler", withExtension: "momd")!
    return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
  
  lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
    // Create the coordinator and store
    var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
    let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("TerpScheduler.sqlite")
    var error: NSError? = nil
    var configuration = [String: AnyObject]()
    configuration[NSMigratePersistentStoresAutomaticallyOption] = true
    configuration[NSInferMappingModelAutomaticallyOption] = true
    var failureReason = "There was an error creating or loading the application's saved data."
    do {
      try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: configuration)
    } catch var error1 as NSError {
      error = error1
      coordinator = nil
      // Report any error we got.
      let dict = NSMutableDictionary()
      dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
      dict[NSLocalizedFailureReasonErrorKey] = failureReason
      dict[NSUnderlyingErrorKey] = error
      error = NSError(domain: "TERPSCHEDULER_PERSISTENCE", code: 9999, userInfo: dict as [NSObject : AnyObject])
      // Replace this with code to handle the error appropriately.
      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      NSLog("Unresolved error \(error), \(error!.userInfo)")
      //abort()
    } catch {
      fatalError()
    }
    return coordinator
    }()
  
  lazy var managedObjectContext: NSManagedObjectContext? = {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
    let coordinator = self.persistentStoreCoordinator
    if coordinator == nil {
      return nil
    }
    var managedObjectContext = NSManagedObjectContext()
    managedObjectContext.persistentStoreCoordinator = coordinator
    return managedObjectContext
    }()
  
  // MARK: - Core Data Saving support
  
  func saveContext () {
    if let moc = self.managedObjectContext {
      var error: NSError? = nil
      if moc.hasChanges {
        do {
          try moc.save()
        } catch let error1 as NSError {
          error = error1
          // Replace this implementation with code to handle the error appropriately.
          // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
          NSLog("Unresolved error \(error), \(error!.userInfo)")
          abort()
        }
      }
    }
  }
  
}

