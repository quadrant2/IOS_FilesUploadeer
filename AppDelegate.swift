//
//  AppDelegate.swift
//  Upload to AWSS3 Bucket
//
//  Created by TIEGO Ouedraogo on 6/22/22.
//

import UIKit
import AWSS3
import AWSMobileClient

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.initializeS3()
        return true
    }

    func application(_ application: UIApplication,
                        handleEventsForBackgroundURLSession identifier: String,
                        completionHandler: @escaping () -> Void) {
           
           AWSMobileClient.sharedInstance().initialize { (userState, error) in
               guard error == nil else {
                   print("Error initializing AWSMobileClient. Error: \(error!.localizedDescription)")
                   return
               }
               print("AWSMobileClient initialized.")
           }
           
           //provide the completionHandler to the TransferUtility to support background transfers.
           AWSS3TransferUtility.interceptApplication(application,
                                                     handleEventsForBackgroundURLSession: identifier,
                                                     completionHandler: completionHandler)
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
    func initializeS3() {

    let poolId = "us-east-1:273e8501-86d8-4f31-b468-2ecb1139bd66"

let credentialsProvider:AWSCognitoCredentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast1,
                          identityPoolId: poolId)

        
let configuration = AWSServiceConfiguration(region:.USEast1, credentialsProvider: credentialsProvider)
        
                       AWSServiceManager.default().defaultServiceConfiguration = configuration
        

    }

}

