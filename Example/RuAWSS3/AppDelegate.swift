//
//  AppDelegate.swift
//  RuAWSS3
//
//  Created by Macabeus on 12/25/2016.
//  Copyright (c) 2016 Macabeus. All rights reserved.
//

import UIKit
import RuAWSS3

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // IMPORTANT: Set your AWS S3 credentials
        /*AmazonS3.shared.performCredentials(
            regionType: ** YOUR REGION **,
            identityPoolId: ** YOUR POOL ID **
        )*/
    
        return true
    }

}

