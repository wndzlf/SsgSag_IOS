//
//  AppDelegate.swift
//  SsgSag
//
//  Created by admin on 24/12/2018.
//  Copyright © 2018 wndzlf. All rights reserved.
//
import UIKit
import CoreData
import NaverThirdPartyLogin

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var loginViewController: UIViewController?
    var mainViewController: UIViewController?
    
    // Override point for customization after application launch.
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        naverLogin()
        
        window = UIWindow(frame: UIScreen.main.bounds)
    
        setWindowRootViewController()

        window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if KOSession.handleOpen(url) {
            return true
        }
        return false
    }

    
    private func setWindowRootViewController() {
        if let isAutoLogin = UserDefaults.standard.object(forKey: "isAutoLogin") as? Bool {
            if isAutoLogin {
                if isTokenExist() {
                    window?.rootViewController = TapbarVC()
                } else {
                    let loginStoryBoard = UIStoryboard(name: "LoginStoryBoard", bundle: nil)
                    let loginVC = loginStoryBoard.instantiateViewController(withIdentifier: "Login")
                    
                    window?.rootViewController = loginVC
                }
            } else {
                let loginStoryBoard = UIStoryboard(name: "LoginStoryBoard", bundle: nil)
                let loginVC = loginStoryBoard.instantiateViewController(withIdentifier: "Login")
                
                window?.rootViewController = loginVC
            }
        } else {
            let loginStoryBoard = UIStoryboard(name: "LoginStoryBoard", bundle: nil)
            let loginVC = loginStoryBoard.instantiateViewController(withIdentifier: "Login")
            window?.rootViewController = loginVC
        }
    }
    
    private func isTokenExist() -> Bool {
        if let _ = UserDefaults.standard.object(forKey: "SsgSagToken") {
            return true
        } else {
            return false
        }
    }
    
    private func naverLogin() {
        let instance = NaverThirdPartyLoginConnection.getSharedInstance()
        instance?.isInAppOauthEnable = true // --- 1
        instance?.isNaverAppOauthEnable = true // --- 2
        instance?.isOnlyPortraitSupportedInIphone() // --- 3
        // --- 4
        instance?.serviceUrlScheme = kServiceAppUrlScheme
        instance?.consumerKey = kConsumerKey
        instance?.consumerSecret = kConsumerSecret
        instance?.appName = kServiceAppName
        
        
        
        
    }
    
    fileprivate func hasToken() -> Bool {
         if UserDefaults.standard.object(forKey: "SsgSagToken") != nil {
            return true
         } else {
            return false
        }
    }
    
    fileprivate func setupEntryController() {
        let loginStoryBoard = UIStoryboard(name: "LoginStoryBoard", bundle: nil)
        
        let navigationController = loginStoryBoard.instantiateViewController(withIdentifier: "LoginNavigator") as! UINavigationController
        let navigationController2 = loginStoryBoard.instantiateViewController(withIdentifier: "LoginNavigator") as! UINavigationController
        let mainVC = TapbarVC() as UIViewController
        let loginVC = loginStoryBoard.instantiateViewController(withIdentifier: "Login") as UIViewController
    
        navigationController2.pushViewController(mainVC, animated: true)
        self.mainViewController = navigationController2
        
        navigationController.pushViewController(loginVC, animated: true)
        self.loginViewController = navigationController
    }
    
    fileprivate func reloadRootViewController() {
        let isOpened = KOSession.shared().isOpen()
        let hasToken = self.hasToken()

        if !isOpened || !hasToken {
            let mainViewController = self.mainViewController as! UINavigationController
            mainViewController.popToRootViewController(animated: true)
        }
        self.window?.rootViewController = isOpened ? self.mainViewController : self.loginViewController
        self.window?.rootViewController = hasToken ? self.mainViewController : self.loginViewController

        self.window?.makeKeyAndVisible()
        
    }
    
    @objc func kakaoSessionDidChangeWithNotification() {
        reloadRootViewController()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        KOSession.handleDidEnterBackground()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        KOSession.handleDidBecomeActive()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        //NaverThirdPartyLoginConnection.getSharedInstance()?.application(app, open: url, options: options)
        
        var naverSignInResult = false
        
        if url.scheme == kServiceAppUrlScheme {
            if url.host == kCheckResultPage {
                let loginConn = NaverThirdPartyLoginConnection.getSharedInstance()
                let resultType = loginConn?.receiveAccessToken(url)
                
                if resultType == SUCCESS {
                    naverSignInResult = true
                }
            }
        }
        
        return naverSignInResult
//
//        if KOSession.handleOpen(url) {
//            return true
//        }
//
//        return false
    }
    
    func application(application: UIApplication, handleOpenURL url: URL) -> Bool {
        if KOSession.isKakaoAccountLoginCallback(url) {
            return KOSession.handleOpen(url)
        }
        return false
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        
        let container = NSPersistentContainer(name: "SsgSag")
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
}
