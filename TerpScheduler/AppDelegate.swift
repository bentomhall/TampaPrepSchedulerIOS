//
//  AppDelegate.swift
//  TerpScheduler
//
//  Created by Ben Hall on 12/18/14.
//  Copyright (c) 2014 Tampa Preparatory School. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    let defaultValues = ["isDataInitialized": false, "isMiddleStudent": false, "shouldShadeStudyHall": true, "shouldShowExtraRow": true, "shouldNotifyWhen": "Evening", "lastUpdate": 0.0] as [String : Any]
    Foundation.UserDefaults.standard.register(defaults: defaultValues)
    let schoolYear = getSchoolYear(Date())
    if !DateRepository.isScheduleLoadedFor(schoolYear: schoolYear, inContext: managedObjectContext!) {
        let filename = "schedule." + String(schoolYear)
      scheduleLoader.loadSchedule(fromFiles: [filename])
      
    }
    do {
        try scheduleTypes = scheduleLoader.loadScheduleTypesFromDisk(defaults: userDefaults)
    } catch let error as NSError {
      NSLog("Error Loading default schedule types: %@. Installation Corrupted", error)
      abort()
    }
    application.applicationIconBadgeNumber = 0
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: self.permissions)
    let notificationManager = NotificationManager()
    UNUserNotificationCenter.current().delegate = notificationManager
    dataManager = DataManager(notificationHelper: notificationManager)
    userColors = UserColors(defaults: userDefaults)
    setNavBarColor(color: userColors!.navigationBarTint)
    return true
  }

  func permissions(granted: Bool, error: Error?) {
    userDefaults.notificationPermissionGranted = granted
  }
  
  func setNavBarColor(color: UIColor) {
    UINavigationBar.appearance().barTintColor = color
  }
  
  lazy var scheduleLoader: SemesterScheduleLoader = SemesterScheduleLoader(context: self.managedObjectContext!)
  
  var scheduleTypes: ScheduleTypeData?

  lazy var userDefaults = CustomUserDefaults()
  var dataManager: DataManager?
  var userColors: UserColors?

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. 
    //This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) 
    //or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, 
    //and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data,
    //invalidate timers, and store enough application state information 
    //to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, 
    //this method is called instead of applicationWillTerminate: when the user quits.
    self.saveContext()
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; 
    //here you can undo many of the changes made on entering the background.
  }
  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. 
    //If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. 
    //Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    self.saveContext()
  }

  // MARK: - Core Data stack

  lazy var applicationDocumentsDirectory: URL = {
    // The directory the application uses to store the Core Data store 
    //file. This code uses a directory named "com.tampaprep.TerpScheduler" 
    //in the application's documents Application Support directory.
    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return urls[urls.count-1]
    }()

  lazy var managedObjectModel: NSManagedObjectModel = {
    // The managed object model for the application. 
    //This property is not optional. 
    //It is a fatal error for the application not to be able to find and load its model.
    let modelURL = Bundle.main.url(forResource: "TerpScheduler", withExtension: "momd")!
    return NSManagedObjectModel(contentsOf: modelURL)!
    }()

  lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
    // The persistent store coordinator for the application. 
    //This implementation creates and return a coordinator, 
    //having added the store for the application to it. 
    //This property is optional since there are legitimate error conditions 
    //that could cause the creation of the store to fail.
    // Create the coordinator and store
    var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
    let url = self.applicationDocumentsDirectory.appendingPathComponent("TerpScheduler.sqlite")
    var configuration = [String: AnyObject]()
    configuration[NSMigratePersistentStoresAutomaticallyOption] = true as AnyObject?
    configuration[NSInferMappingModelAutomaticallyOption] = true as AnyObject?
    var failureReason = "There was an error creating or loading the application's saved data."
    do {
      try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: configuration)
    } catch var error as NSError {
        do {
            try coordinator!.destroyPersistentStore(at: url, ofType: NSSQLiteStoreType, options: nil)
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: configuration)
        } catch var error as NSError {
            coordinator = nil
            // Report any error we got.
            var dict = [String: Any]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "TERPSCHEDULER_PERSISTENCE", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate.
            //You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error.userInfo)")
        }
      
      //abort()
    } catch {
      fatalError()
    }
    return coordinator
    }()

  lazy var managedObjectContext: NSManagedObjectContext? = {
    // Returns the managed object context for the application 
    //(which is already bound to the persistent store coordinator for the application.)
    //This property is optional since there are legitimate error conditions 
    //that could cause the creation of the context to fail.
    let coordinator = self.persistentStoreCoordinator
    if coordinator == nil {
      return nil
    }
    var managedObjectContext = NSManagedObjectContext.init(concurrencyType: .mainQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = coordinator
    return managedObjectContext
    }()

  // MARK: - Core Data Saving support

  func saveContext () {
    if let moc = self.managedObjectContext {
      if moc.hasChanges {
        do {
          try moc.save()
        } catch let error as NSError {
          // Replace this implementation with code to handle the error appropriately.
          // abort() causes the application to generate a crash log and terminate. 
          //You should not use this function in a shipping application, although it may be useful during development.
          NSLog("Unresolved error \(error), \(error.userInfo)")
          //abort()
        }
      }
    }
  }

}
