//
//  AppDelegate.swift
//  FontShow
//
//  Created by 丁诚 on 16/6/5.
//  Copyright © 2016年 philipding. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    let splitVC = self.window?.rootViewController as! UISplitViewController
    let navC = splitVC.viewControllers[splitVC.viewControllers.count - 1] as! UINavigationController
    navC.topViewController?.navigationItem.leftBarButtonItem = splitVC.displayModeButtonItem()
    splitVC.delegate = self
    
    return true
  }
}

extension AppDelegate: UISplitViewControllerDelegate {
  func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
    guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
    guard let topAsDetailController = secondaryAsNavController.topViewController as? PreviewViewController else { return false }
    return topAsDetailController.previewFontNames.count == 0
  }
}