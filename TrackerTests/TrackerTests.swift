//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Андрей Мерзликин on 04.03.2024.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    // MARK: You can reset all results
    let reset = false
    
    // MARK: Snapshot tests - TabBarController(Main screen)
    func testTabBarControllerDarkTheme() {
        let viewController = TabBarController()
        sleep(1)
        assertSnapshot(of: viewController, as: .image(traits: UITraitCollection(userInterfaceStyle: .dark)), record: reset)
    }
    func testTabBarControllerLightTheme() {
        let viewController = TabBarController()
        sleep(1)
        assertSnapshot(of: viewController, as: .image(traits: UITraitCollection(userInterfaceStyle: .light)), record: reset)
    }
    
    // MARK: Snapshot tests - TrackersViewController
    func testTrackersViewControllerDarkTheme() {
        let viewController = TrackersViewController()
        sleep(1)
        assertSnapshot(of: viewController, as: .image(traits: UITraitCollection(userInterfaceStyle: .dark)), record: reset)
    }
    func testTrackersViewControllerLightTheme() {
        let viewController = TrackersViewController()
        sleep(1)
        assertSnapshot(of: viewController, as: .image(traits: UITraitCollection(userInterfaceStyle: .light)), record: reset)
    }
    
    // MARK: Snapshot tests - ChooseTypeOfTracker
    func testChooseTypeOfTrackerDarkTheme() {
        let viewController = NewTrackerViewController()
        sleep(1)
        assertSnapshot(of: viewController, as: .image(traits: UITraitCollection(userInterfaceStyle: .dark)), record: reset)
    }
    func testChooseTypeOfTrackerLightTheme() {
        let viewController = NewTrackerViewController()
        sleep(1)
        assertSnapshot(of: viewController, as: .image(traits: UITraitCollection(userInterfaceStyle: .light)), record: reset)
    }
    
    // MARK: Snapshot tests - NewTrackerViewController
    func testNewTrackerViewControllerDarkTheme() {
        let viewController = NewTrackerViewController()
        sleep(1)
        assertSnapshot(of: viewController, as: .image(traits: UITraitCollection(userInterfaceStyle: .dark)), record: reset)
    }
    func testNewTrackerViewControllerLightTheme() {
        let viewController = NewTrackerViewController()
        sleep(1)
        assertSnapshot(of: viewController, as: .image(traits: UITraitCollection(userInterfaceStyle: .light)), record: reset)
    }
    
    // MARK: Snapshot tests - CategoriesViewController
    func testCategoriesViewControllerDarkTheme() {
        let viewController = CategoryViewController()
        sleep(1)
        assertSnapshot(of: viewController, as: .image(traits: UITraitCollection(userInterfaceStyle: .dark)), record: reset)
    }
    func testCategoriesViewControllerLightTheme() {
        let viewController = CategoryViewController()
        sleep(1)
        assertSnapshot(of: viewController, as: .image(traits: UITraitCollection(userInterfaceStyle: .light)), record: reset)
    }
    
    // MARK: Snapshot tests - TimetableViewController
    func testTimetableViewControllerDarkTheme() {
        let viewController = ScheduleViewCell()
        sleep(1)
        assertSnapshot(of: viewController, as: .image(traits: UITraitCollection(userInterfaceStyle: .dark)), record: reset)
    }
    func testTimetableViewControllerLightTheme() {
        let viewController = ScheduleViewCell()
        sleep(1)
        assertSnapshot(of: viewController, as: .image(traits: UITraitCollection(userInterfaceStyle: .light)), record: reset)
    }
}

