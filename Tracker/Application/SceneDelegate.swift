//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Андрей Мерзликин on 15.11.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: scene)
        
        let defaults = UserDefaults.standard
        let isFirstLaunch = !defaults.bool(forKey: "FirstLaunch")
        
        if isFirstLaunch {
            defaults.set(true, forKey: "FirstLaunch")
            window?.rootViewController = OnboardingViewController()
        } else {
            window?.rootViewController = TabBarController()
        }
        window?.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}


