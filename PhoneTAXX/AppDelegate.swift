//
//  AppDelegate.swift
//  PhoneTAXX
//
//  Created by Jordan Parker on 06/04/21.
//

import UIKit
import CoreData
import Firebase
import FirebaseAuth
import IQKeyboardManagerSwift
import GoogleSignIn
import UserNotifications
import  CallKit
import Messages
import FirebaseDatabase
import FirebaseMessaging
import FirebaseInstallations
import FirebaseCore
//import FirebaseInstanceID
//import FirebaseMessaging
let userDefaults = UserDefaults.standard
public var screenTimeCount = 0
public  var isCallMade = false
public var callDuration = 0
public var callIncoming = false
public var callOutGoing = false
public var callDial = false
public var callConnect = false
public var callIncomingConnect = false
public var callCount = 0
@main

class AppDelegate: UIResponder, UIApplicationDelegate,GIDSignInDelegate,UNUserNotificationCenterDelegate, MessagingDelegate {
    var window: UIWindow?
    var callObserver: CXCallObserver!
    var timer:Timer?
    var timerForApp : Timer?
    var totalTime = 0
    var screenTime = 0
    var timeStampB = 0
    override init() {
        super.init()
        FirebaseApp.configure()
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.ConnectToFCM()
        timerForApp = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(AppTime), userInfo: nil, repeats: true)
       
        
        callObserver = CXCallObserver()
        callObserver.setDelegate(self, queue: nil)
        
        Thread.sleep(forTimeInterval: 3.0)
        // Override point for customization after application launch.
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        IQKeyboardManager.shared.enable = true
    
       // FirebaseApp.configure()
        GIDSignIn.sharedInstance()?.clientID = "416884605991-9cn8haugss9hao8e37arvp5bhbqj41j9.apps.googleusercontent.com"
              GIDSignIn.sharedInstance()?.delegate = self
        
        if UserDefaults.standard.bool(forKey: "isLoggedIn") == true{
            let storyboard : UIStoryboard = UIStoryboard(name:"Main", bundle: nil)
            let navigationController : UINavigationController = storyboard.instantiateInitialViewController() as! UINavigationController
            let rootViewController:UIViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            navigationController.viewControllers = [rootViewController]
            //self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = navigationController
            self.window?.makeKeyAndVisible()
        }
        
        
        if #available(iOS 10.0, *) {
            //UIApplication.shared.statusBarStyle = .darkContent
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        } else {
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        
        
        
        if #available(iOS 13.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert],completionHandler: { (granted, error) in })
                application.registerForRemoteNotifications()

        }else {
            let notifificationSettings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(notifificationSettings)
            UIApplication.shared.registerForRemoteNotifications()

        }
//        Messaging.messaging().delegate = self
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("Screen time after termination is ", screenTimeCount)
        timerForApp?.invalidate()
        
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground")
        if callOutGoing{
            timeStampB = Int(NSDate().timeIntervalSince1970)
        }
        print("Screen time after termination is ", screenTimeCount)
        timerForApp?.invalidate()
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("applicationWillEnterForeground")
        if callOutGoing{
            let timeStampE = Int(NSDate().timeIntervalSince1970)
            let timeOfCall = timeStampE - timeStampB
            print("call time using time stamp is ",timeOfCall)
            callDuration = timeOfCall
        }
        timerForApp = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(AppTime), userInfo: nil, repeats: true)
        
    }
   
    @objc func AppTime(){
        if screenTime >= 0 {
            screenTime = screenTime + 1
            screenTimeCount = screenTime
            print("Screen time is ", screenTimeCount)
            NotificationCenter.default.post(name: Notification.Name("changeScreenTime"), object: nil, userInfo: nil)
            //resendCodeLabel.text = "Resend code in 00:\(totalSecond)"
        }
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification notification: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(notification) {
            completionHandler(.noData)
            return
        }
        // This notification is not auth related, developer should handle it.
       // handleNotification(notification)
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
          
          let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
          print("dtoken=", deviceTokenString)
      Messaging.messaging().apnsToken = deviceToken
        
        // Pass device token to auth
         Auth.auth().setAPNSToken(deviceToken, type: .unknown)
      }

    
        func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
            print("user email: \(user.profile.email )")
        }
    
    
        func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
            return GIDSignIn.sharedInstance().handle(url)
        }

    
    func ConnectToFCM() {
        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = true
        Messaging.messaging().token { token, error in
           // Check for error. Otherwise do what you will with token here
            print("FCM TOKEN IS \(token ?? "")")
            UserDefaults.standard.set(token ?? "", forKey: "newFcmToken")
            print("ERROR IS TOKEN \(error?.localizedDescription)")
        }
    }

/*    // MARK: UISceneSession Lifecycle

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
*/
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "PhoneTAXX")
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
//MARK: - Call Observer

extension AppDelegate: CXCallObserverDelegate {
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        if call.hasEnded == true {
            print("Disconnected")
            if callDial == true  && callConnect == false {
                NotificationCenter.default.post(name: Notification.Name("createEmptyCallEntry"), object: nil, userInfo: nil)
            }
            timer?.invalidate()
        }
        if call.isOutgoing == true && call.hasConnected == false {
            print("Dialing")
            print("callOutgoing",callOutGoing)
            callDial = true
           // let timeStamp = Int(NSDate().timeIntervalSince1970)
        }
        if call.isOutgoing == false && call.hasConnected == false && call.hasEnded == false {
            print("Incoming")
            callIncoming = true
        }

        if call.hasConnected == true && call.hasEnded == false {
            print("Connected",call.uuid.uuidString)
            if callDial{
               // callOutGoing = true
                callConnect = true
                NotificationCenter.default.post(name: Notification.Name("createCallEntry"), object: nil, userInfo: nil)
            } else if callIncoming{
                callIncomingConnect = true
                //timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
            }
            
        }
    }
//    @objc func countdown() {
//        print("Countdown Start ")
//        if totalTime >= 0 {
//            totalTime = totalTime + 1
//            callDuration = totalTime
//            print("call duration time is ", totalTime)
//            //resendCodeLabel.text = "Resend code in 00:\(totalSecond)"
//        }
//
//    }
    
    
    
    private func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        NSLog("[RemoteNotification] didRefreshRegistrationToken: \(fcmToken)")
        user.set(fcmToken, forKey: "fcmToken")
         print("fcmToken2=",fcmToken)
        
        
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
//       UIApplication.shared.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 1
        print("mess222=")
        //handleNotification(userInfo: userInfo)  //This is main for foreground notifications
        //NSLog("[RemoteNotification] applicationState: \(applicationStateString) didReceiveRemoteNotification for iOS9: \(userInfo)")
        if UIApplication.shared.applicationState == .active {
                  // TODO: Handle foreground notification
              }
              else if UIApplication.shared.applicationState == .background {
                  //  TODO: Handle background notification
              }
    }
    /*
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?)
    {
        print("token===",fcmToken)
       // user.set(fcmToken, forKey: "fcmToken")
        
        InstanceID.instanceID().instanceID { (result, error) in
          if let error = error {
            print("Error fetching remote instance ID: \(error)")
          } else if let result = result {
            print("Remote instance ID token: \(result.token)")
          
             user.set(result.token, forKey: "fcmToken")
          }
        }
        
    }
    */
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken ?? "")")
        if let validToken = fcmToken{
            let dataDict:[String: String] = ["token": validToken]
            NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        }
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
}
