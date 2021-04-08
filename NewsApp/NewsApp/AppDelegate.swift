//
//  AppDelegate.swift
//  NewsApp
//
//  Created by Дарья Астапова on 18.03.21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        if let window = self.window {
            let navigationController = UINavigationController()
            let vc = NANewsTableViewController()
            navigationController.viewControllers = [vc]
            
            let requestParameters: [String: String] = ["from": Date().formatDateToString(),
                                                       "to": Date().formatDateToString()]
            
            NANetworking.shared.getNews(parameters: requestParameters) {
                Swift.debugPrint("AppDelegate completion hanler")
                vc.readNews(date: Date())
            } errorHandler: { (error) in
                Swift.debugPrint("First request with error - \(error)")
            }
            
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }
        
        return true
    }
}

