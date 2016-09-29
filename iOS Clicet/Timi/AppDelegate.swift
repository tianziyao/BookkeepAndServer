//
//  AppDelegate.swift
//  Timi
//
//  Created by 田子瑶 on 16/8/30.
//  Copyright © 2016年 田子瑶. All rights reserved.
//

import UIKit
import CoreData
import RESideMenu

private var ScreenWithRatio = UIScreen.main.bounds.width / 375
let firmAccountPath = "AccountBooks/firmAccount.archiver"

extension AppDelegate:RESideMenuDelegate{

}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var booksArray:[AccountBookBtn] = []

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        //在沙盒中创建目录
        initWithCreateDirectory()
        initWithCreateAccountBooks()
        
        //找到正在被使用的账本
        var item:AccountBookBtn!
        let path = String.createFilePathInDocumentWith(firmAccountPath) ?? ""
        if let accountsBtns = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? [AccountBookBtn]{
            for i in 0...accountsBtns.count - 1{
                if accountsBtns[i].selectedFlag{
                    item = accountsBtns[i]
                }
            }
        }
        window = UIWindow(frame: UIScreen.main.bounds)
        let mainVCModel = MainVCModel()
        let leftMenuVC = MainViewController(model: mainVCModel)
        let singleAccountModel = SingleAccountModel(initDBName: item.dataBaseName, accountTitle: item.btnTitle)
        //print("\(item.dataBaseName) \(item.btnTitle)")
        let homeVC = SingleAccountVC(model: singleAccountModel)
        let sideMenu = RESideMenu.init(contentViewController: homeVC, leftMenuViewController: leftMenuVC, rightMenuViewController: nil)
        sideMenu?.delegate = self
        sideMenu?.contentViewInPortraitOffsetCenterX = 150 * ScreenWithRatio
        sideMenu?.contentViewShadowEnabled = true
        sideMenu?.contentViewShadowOffset = CGSize(width: -2, height: -2)
        sideMenu?.contentViewShadowColor = UIColor.black
        sideMenu?.scaleContentView = false
        sideMenu?.scaleMenuView = false
        sideMenu?.fadeMenuView = false
        //window?.rootViewController = sideMenu
        window?.makeKeyAndVisible()
        
        let nav = UINavigationController(rootViewController: sideMenu!)
        
        window?.rootViewController = nav
        
        return true
    }
    
    fileprivate func initWithCreateDirectory(){
        String.createDirectoryInDocumentWith("DatabaseDoc")
        String.createDirectoryInDocumentWith("AccountPhoto")
        String.createDirectoryInDocumentWith("AccountBooks")
    }
    fileprivate func initWithCreateAccountBooks(){
        let path = String.createFilePathInDocumentWith(firmAccountPath) ?? ""
        var booksArray:[AccountBookBtn] = []
        if FileManager.default.fileExists(atPath: path) == false {
            //初始化账本页
            let booksitem = AccountBookBtn(title: "日常账本", count: "0笔", image: "book_cover_0", flag: true, dbName: "DatabaseDoc/AccountModel.db")
            booksArray.append(booksitem)
            booksArray.append(AccountBookBtn(title: "", count: "", image: "menu_cell_add", flag: false, dbName: ""))
            NSKeyedArchiver.archiveRootObject(booksArray, toFile: path)
        }
        self.booksArray = booksArray
    }


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "space.tianziyao.Timi" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Timi", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}

