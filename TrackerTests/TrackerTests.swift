//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Андрей Мерзликин on 19.03.2024.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    // MARK: You can reset all results
    let reset = false
    
    // MARK: Snapshot tests - TabBarController(Main screen)
    func testTabBarControllerDarkTheme() {
        let viewController = TabBarViewController()
        sleep(1)
        assertSnapshot(of: viewController, as: .image(traits: UITraitCollection(userInterfaceStyle: .dark)), record: reset)
    }
    func testTabBarControllerLightTheme() {
        let viewController = TabBarViewController()
        sleep(1)
        assertSnapshot(of: viewController, as: .image(traits: UITraitCollection(userInterfaceStyle: .light)), record: reset)
    }
    

}

