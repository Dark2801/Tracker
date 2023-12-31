//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Андрей Мерзликин on 24.12.2023.
//

import UIKit

protocol OnboardingPageDelegate: AnyObject {
    func didTapNextButton()
    var currentPageIndex: Int { get set }
}

final class OnboardingViewController: UIPageViewController {
    private let pageControl = UIPageControl()
    
    var currentPageIndex = 0
    
    lazy var pages: [UIViewController] = {
        let pageOne = OnboardingFirst()
        pageOne.delegate = self
        
        let pageTwo = OnboardingSecond()
        
        return [pageOne, pageTwo]
    }()
    
    private var isAnimating = false
    
    init(transitionStyle: UIPageViewController.TransitionStyle) {
        super.init(transitionStyle: transitionStyle, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupPageControl()
    }
    
    // MARK: Functions
    private func setupPageControl() {
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        delegate = self
        dataSource = self
        pageControl.currentPageIndicatorTintColor = .ypBlackDay
        pageControl.pageIndicatorTintColor = .yp_Gray
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.addTarget(self, action: #selector(pageControlTapped), for: .valueChanged)
    }
    
    // MARK: Selectors
    
    @objc func pageControlTapped(_ sender: UIPageControl) {
        let tappedPageIndex = sender.currentPage
        
        if isAnimating {
            return
        }
        
        if tappedPageIndex != currentPageIndex {
            if tappedPageIndex >= 0 && tappedPageIndex < pages.count {
                let targetPage = pages[tappedPageIndex]
                guard let currentViewController = viewControllers?.first else {
                    return
                }
                if let currentIndex = pages.firstIndex(of: currentViewController) {
                    let direction: UIPageViewController.NavigationDirection = tappedPageIndex > currentIndex ? .forward : .reverse
                    
                    isAnimating = true
                    
                    self.setViewControllers([targetPage], direction: direction, animated: true) { [weak self] _ in
                        self?.isAnimating = false
                        self?.currentPageIndex = tappedPageIndex
                    }
                }
            }
        }
    }

}

// MARK: - UIPageViewControllerDataSource
extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1

        guard previousIndex >= 0 else {
            currentPageIndex = previousIndex
            return pages.last
        }
        
        return pages[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1

        guard nextIndex < pages.count else {
            currentPageIndex = nextIndex
            return pages.first
        }
        
        return pages[nextIndex]
    }
}

// MARK: - UIPageViewControllerDelegate
extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}

// MARK: - OnboardingPageDelegate
extension OnboardingViewController: OnboardingPageDelegate {
    func didTapNextButton() {
        goToNextPage()
    }
    
    private func goToNextPage() {
        guard let currentViewController = viewControllers?.first else {
            return
        }
        if let currentIndex = pages.firstIndex(of: currentViewController) {
            let nextIndex = currentIndex + 1
            
            if nextIndex < pages.count {
                let nextViewController = pages[nextIndex]
                setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
                pageControl.currentPage = nextIndex
            }
        }
        currentPageIndex = 1
    }
}

// MARK: - Setup Views and Constraints
private extension OnboardingViewController {
    func setupViews() {
        view.addSubviews(pageControl)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
