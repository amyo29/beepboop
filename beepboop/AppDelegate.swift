//
//  AppDelegate.swift
//  beepboop
//
//  Created by Alvin Lo on 3/17/21.
//

import UIKit
import CoreData
import Firebase
import GoogleSignIn
import FBSDKCoreKit

@main

class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, UNUserNotificationCenterDelegate{

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UITabBar.appearance().barTintColor = UIColor(red: 0.04, green: 0.83, blue: 0.83, alpha: 1.00)
        UITabBar.appearance().tintColor = UIColor(red: 0.97, green: 0.16, blue: 0.60, alpha: 1.00)
        UITabBar.appearance().unselectedItemTintColor = UIColor.white
        
        // Firebase config
        FirebaseApp.configure()
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        // Set up notification handling
        let center = UNUserNotificationCenter.current()
            center.delegate = self

        //To get permissions from user:
        let options: UNAuthorizationOptions = [.alert, .sound, .badge];
        center.requestAuthorization(options: options) {
            (granted, error) in
            if !granted {
                print("Something went wrong when requesting notification permission from user.")
            }
        }
        
        return true
    }

    // MARK: UserNotificationCenter Snoozing
    /*
     userNotificationCenter:center:willPresent:completionHandler deals with incoming local notifications, we turn off the settings if snooze is enabled.
     */
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
        var fetchedResults: [NSManagedObject]
        
        do {
            try fetchedResults = context.fetch(request) as! [NSManagedObject]
            if fetchedResults.count > 0 {
                if let snooze = fetchedResults[0].value(forKey: "snoozeEnabled") as? Bool {
                    if snooze { // Passing in empty list disables notifications that come through
                        completionHandler([])
                    }
                    else { // not too sure if this line is necessary
                        completionHandler([.badge, .banner, .list, .sound])
                    }
                }
            }
            else {
                completionHandler([.badge, .banner, .list, .sound])
            }
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let target = response.notification.request.identifier
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let window = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window
        guard let metadataVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else { return }
        window?.rootViewController = metadataVC
        window?.makeKeyAndVisible()
        metadataVC.updateAlarmsFirestore()
        metadataVC.selectedAlarm = target
        window?.rootViewController?.performSegue(withIdentifier: "HomeToAlarmDisplayIdentifier", sender: target)
        completionHandler()
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        ApplicationDelegate.shared.application(
                    application,
                    open: url,
                    sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                    annotation: options[UIApplication.OpenURLOptionsKey.annotation]
                )
        
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "beepboop")
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
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
              print("The user has not signed in before or they have since signed out.")
            } else {
              print("error signing into Google: \(error.localizedDescription)")
            }
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
          if let error = error {
            print("authentication error \(error.localizedDescription)")
            return
          }
          // User is signed in
          // ...
        }
//          Info we can pull from user
//          let userId = user.userID                  // For client-side use only!
//          let idToken = user.authentication.idToken // Safe to send to the server
//          let fullName = user.profile.name
//          let givenName = user.profile.givenName
//          let familyName = user.profile.familyName
//          let email = user.profile.email
    }

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

