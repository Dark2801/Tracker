//
//  TabBarViewController.swift
//  Tracker
//
//  Created by Андрей Мерзликин on 14.03.2024.
//

import UIKit

final class TabBarViewController: UITabBarController {

    private let trackerStore = TrackerStore()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBarItems()
    }
    
    // MARK: - Constructor Method
    private func setupBarItems() {
        tabBar.backgroundColor = .yaWhite
        tabBar.tintColor = .yaBlue
        tabBar.barTintColor = .yaGray
        
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.3
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -0.5)
        tabBar.layer.shadowRadius = 0
        
        let trackerViewController = TrackerViewController(trackerStore: trackerStore)
        trackerViewController.tabBarItem = UITabBarItem(
            title: "trackerVC_title".localized,
            image: UIImage(named: "trackerImage"),
            selectedImage: nil
        )
        
        let statisticViewController = StatisticViewController()
        statisticViewController.tabBarItem = UITabBarItem(
            title: "statisticVC_title".localized,
            image: UIImage(named: "statisticImage"),
            selectedImage: nil
        )
        self.viewControllers = [trackerViewController, statisticViewController]
    }
}
