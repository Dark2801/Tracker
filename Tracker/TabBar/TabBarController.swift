//
//  TabBarController.swift
//  Tracker
//
//  Created by Андрей Мерзликин on 03.03.2024.
//

import UIKit

final class TabBarController: UITabBarController {
    
    let trackersViewController = TrackersViewController()
    lazy var statisticsViewController: StatisticsViewController = {
        return StatisticsViewController(trackersViewController: self.trackersViewController)
    }()
    let separatorImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBarView()
        setupTabBarViewController()
        setupSeparator()
    }
}

// MARK: - Private methods to setup UI

private extension TabBarController {
    
    func setupTabBarView() {
        tabBar.tintColor = .ypBlue
        tabBar.backgroundColor = .ypWhiteDay
    }
    
    func setupTabBarViewController() {
        view.backgroundColor = .ypWhiteDay
        
        setupTabBarItem(for: trackersViewController, titleKey: "app.title", image: "Trackers")
        setupTabBarItem(for: statisticsViewController, titleKey: "statistic.title", image: "Statistics")
        
        let viewControllers = [trackersViewController, statisticsViewController]
        selectedIndex = 0
        self.viewControllers = viewControllers.map { controller in
            UINavigationController(rootViewController: controller)
        }
    }
    
    func setupTabBarItem(for viewController: UIViewController, titleKey: String, image: String) {
        viewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString(titleKey, comment: ""),
            image: UIImage(named: image),
            selectedImage: nil
        )
    }
    
    func setupSeparator() {
        self.tabBar.shadowImage = separatorImage
        self.tabBar.backgroundImage = separatorImage
        self.tabBar.layer.borderWidth = 0.50
        self.tabBar.clipsToBounds = true
    }
}

// MARK: - UITabBarControllerDelegate

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        selectedViewController = viewController
    }
}
