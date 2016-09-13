//
//  AppDelegate.swift
//  Widdit
//
//  Created by John McCants on 3/19/16.
//  Copyright © 2016 John McCants. All rights reserved.
//

import UIKit
import CoreData
import Parse
import Bolts
import ParseFacebookUtilsV4
import XCGLogger
import IQKeyboardManagerSwift
import Whisper
import RAMAnimatedTabBarController

let log = XCGLogger.defaultInstance()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        log.setup(.Debug, showThreadName: true, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: "path/to/file", fileLogLevel: .Debug)
        
        log.debug("A debug message")
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().disableToolbarInViewControllerClass(NewPostVC.self)
        IQKeyboardManager.sharedManager().disableToolbarInViewControllerClass(ReplyViewController.self)
        
        IQKeyboardManager.sharedManager().disableDistanceHandlingInViewControllerClass(ReplyViewController.self)

    
        
        //configure push notifications
//        let userNotificationTypes: UIUserNotificationType = [.Alert, .Badge, .Sound]
//        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
//        application.registerUserNotificationSettings(settings)
//        application.registerForRemoteNotifications()

        //app wide navigation bar changes
        UINavigationBar.appearance().barTintColor = UIColor.wddTealColor()
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.wddBodylightinvertcenterFont()]
        UINavigationBar.appearance().translucent = true
        
        
        let image = UIImage(named: "ic_navbar_back")
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -66), forBarMetrics: .Default)
        UINavigationBar.appearance().backIndicatorImage = image
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = image
        
        //app wide bar button item changes
        UITabBar.appearance().tintColor = UIColor.WDTBlueColor()
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.wddBodylightinvertcenterFont()], forState: .Normal)
        

        //app wide status bar changes
        UINavigationBar.appearance().barStyle = .Black

        
        // [Optional] Power your app with Local Datastore. For more info, go to
        // https://parse.com/docs/ios_guide#localdatastore/iOS
        Parse.enableLocalDatastore()
        
        
        //WDTPostModel.initialize()
        // Initialize Parse.
        
        Parse.setApplicationId("CbvFKWpmIJFzo8gKzwPXdM5lN1bGPXu2Ln3lbjGx",
            clientKey: "H6X4RPx8lay4X1YUCu9gA1kPjI2gFxepr152h5x6")
        PFUser.enableRevocableSessionInBackground()
        // [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        // call login function
        
        
        // color of window
        window?.backgroundColor = .whiteColor()

        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)

        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        
        login()
        
        guard let launchOptions = launchOptions else {return true}
        if let userInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject: AnyObject] {
            if let topController = UIApplication.topViewController() {
                let destVC = ActivityVC()
                topController.navigationController?.pushViewController(destVC, animated: true)
            }
            
//            if let postObjectId = userInfo["post"], userObjectId = userInfo["who"] {
//                let post = PFObject(withoutDataWithClassName: "posts", objectId: postObjectId as? String)
//                let query = PFUser.query()
//                query?.whereKey("objectId", equalTo: userObjectId)
//                query?.getObjectInBackgroundWithId(userObjectId as! String, block: { (user: PFObject?, error: NSError?) in
//                    if let topController = UIApplication.topViewController() {
//                        let destVC = ReplyViewController()
//                        destVC.usersPost = post
//                        destVC.toUser = user as! PFUser
//                        topController.navigationController?.pushViewController(destVC, animated: true)
//                    }
//                })
//            }
        }
        

        
        return true
    }
    
    
    func delayedAction() {
        let alert2 = UIAlertController(title: "Ok2", message: "Ok", preferredStyle: .Alert)
        if let topController = UIApplication.topViewController() {
            topController.presentViewController(alert2, animated: true, completion: nil)
        }
    }
    
    
    func login() {
        
        // if loged in
        if let user = PFUser.currentUser() {
            if let signUpFinished = user["signUpFinished"] as? Bool where signUpFinished == true {
//                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                let myTabBar = storyboard.instantiateViewControllerWithIdentifier("TabBar") as! UITabBarController
//                window?.rootViewController = myTabBar
                
                
                let tabBarItem1 = RAMAnimatedTabBarItem(title: "", image: UIImage(named: "ic_tabbar_feed_active"), selectedImage: UIImage(named: "ic_tabbar_feed_active"))
                tabBarItem1.animation = RAMBounceAnimation()
                let feedNC = UINavigationController(rootViewController: FeedVC(style: .Grouped))
                feedNC.tabBarItem = tabBarItem1
                
                let tabBarItem2 = RAMAnimatedTabBarItem(title: "", image: UIImage(named: "ic_tabbar_activity"), selectedImage: UIImage(named: "ic_tabbar_activity"))
                tabBarItem2.animation = RAMBounceAnimation()
                let activityNC = UINavigationController(rootViewController: ActivityVC())
                activityNC.tabBarItem = tabBarItem2
                
                let tabBarItem3 = RAMAnimatedTabBarItem(title: "", image: UIImage(named: "ic_tabbar_profile"), selectedImage: UIImage(named: "ic_tabbar_profile"))
                tabBarItem3.animation = RAMBounceAnimation()
                let profileNC = UINavigationController(rootViewController: ProfileVC())
                profileNC.tabBarItem = tabBarItem3
                profileNC.navigationBarHidden = true

                let controllers = [feedNC, activityNC, profileNC]
                window?.rootViewController = RAMAnimatedTabBarController(viewControllers: controllers)
             
            }
        } else {
            let welcomeNC = UINavigationController(rootViewController: WelcomeVC())
            window?.rootViewController = welcomeNC
        }
    }


    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.channels = ["global"]
        installation.saveInBackground()
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        if let topController = UIApplication.topViewController() {
            
            let userObjectId = userInfo["who"] as! String
            let postObjectId = userInfo["post"] as! String
            
            let post = PFObject(withoutDataWithClassName: "posts", objectId: postObjectId)
            
            let query = PFUser.query()
            query?.whereKey("objectId", equalTo: userObjectId)
            
            query?.getObjectInBackgroundWithId(userObjectId, block: { (userObject: PFObject?, error: NSError?) in
                let destVC = ReplyViewController()
                let user = userObject as! PFUser
                destVC.toUser = user
                destVC.usersPost = post
                
                if topController.isKindOfClass(ReplyViewController) {
                    let replyVC = topController as! ReplyViewController
                    replyVC.requestMessages()
                } else {
                    if let aps = userInfo["aps"] as? NSDictionary {
                        if let alert = aps["alert"] as? NSDictionary {
                            if let message = alert["message"] as? String {
                                let newMessageMurmur = Murmur(title: message)
                                Whistle(newMessageMurmur, action: .Show(2.5))
                            }
                        } else if let alert = aps["alert"] as? String {
                            let newMessageMurmur = Murmur(title: alert)
                            Whistle(newMessageMurmur, action: .Show(2.5))
                        }
                    }
                    
//                    if let alert = userInfo["alert"] as? String {
//                        
//                    }
//                    topController.navigationController?.pushViewController(destVC, animated: true)
                }
            })
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        let installation = PFInstallation.currentInstallation()
        if (installation.badge != 0) {
            installation.badge = 0
            installation.saveEventually()
        }
        FBSDKAppEvents.activateApp()
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool
    {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    

    func applicationWillTerminate(application: UIApplication) {
        
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "JohnMcCants.Widdit" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Widdit", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

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
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
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

extension NSObject {
    var theClassName: String {
        return NSStringFromClass(self.dynamicType)
    }
}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}

extension NSTimer {
    /**
     Creates and schedules a one-time `NSTimer` instance.
     
     - Parameters:
     - delay: The delay before execution.
     - handler: A closure to execute after `delay`.
     
     - Returns: The newly-created `NSTimer` instance.
     */
    class func schedule(delay delay: NSTimeInterval, handler: NSTimer! -> Void) -> NSTimer {
        let fireDate = delay + CFAbsoluteTimeGetCurrent()
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, 0, 0, 0, handler)
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, kCFRunLoopCommonModes)
        return timer
    }
    
    /**
     Creates and schedules a repeating `NSTimer` instance.
     
     - Parameters:
     - repeatInterval: The interval (in seconds) between each execution of
     `handler`. Note that individual calls may be delayed; subsequent calls
     to `handler` will be based on the time the timer was created.
     - handler: A closure to execute at each `repeatInterval`.
     
     - Returns: The newly-created `NSTimer` instance.
     */
    class func schedule(repeatInterval interval: NSTimeInterval, handler: NSTimer! -> Void) -> NSTimer {
        let fireDate = interval + CFAbsoluteTimeGetCurrent()
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, interval, 0, 0, handler)
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, kCFRunLoopCommonModes)
        return timer
    }
}


class RAMBounceAnimation : RAMItemAnimation {
    
    
    override func playAnimation(icon: UIImageView, textLabel: UILabel) {
        playBounceAnimation(icon)
        textLabel.textColor = textSelectedColor
    
    }
    
    override func deselectAnimation(icon: UIImageView, textLabel: UILabel, defaultTextColor: UIColor, defaultIconColor: UIColor) {
        textLabel.textColor = defaultTextColor
    
    }
    
    override func selectedState(icon: UIImageView, textLabel: UILabel) {
        textLabel.textColor = textSelectedColor
    }
    
    func playBounceAnimation(icon : UIImageView) {
        
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [1.0 ,1.4, 0.9, 1.15, 0.95, 1.02, 1.0]
        bounceAnimation.duration = NSTimeInterval(duration)
        bounceAnimation.calculationMode = kCAAnimationCubic
        
        icon.layer.addAnimation(bounceAnimation, forKey: "bounceAnimation")
        
    }
    
}


