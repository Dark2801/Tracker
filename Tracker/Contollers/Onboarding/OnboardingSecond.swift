//
//  OnboardingSecond.swift
//  Tracker
//
//  Created by Андрей Мерзликин on 24.12.2023.
//

import UIKit

final class OnboardingSecond: UIViewController {
    private let backgroundImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "secondBackground")
        return imageView
    }()
    private let labelOnboarding: UILabel = {
        let label = UILabel()
        label.text = "Даже если это не литры воды и йога"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .ypBlackDay
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    private lazy var tapButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypBlackDay
        button.setTitle("Вот это технологии!", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypWhiteDay, for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(showTabBar), for: .touchUpInside)
        button.addTarget(self, action: #selector(touchDown), for: .touchDown)
        button.addTarget(self, action: #selector(touchUpOutside), for: .touchUpOutside)
        return button
    }()
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    // MARK: Functions
    private func animateButton(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.1, animations: { [weak self] in
            self?.tapButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { [weak self] _ in
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
                self?.tapButton.transform = CGAffineTransform.identity
                self?.tapButton.alpha = 0.0
                self?.labelOnboarding.alpha = 0.0
            }, completion: { _ in
                completion()
            })
        }
    }
    
    private func performTransitionToTabBar() {
        let tabBarController = TabBarController()
        if let window = UIApplication.shared.windows.first {
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                window.rootViewController = tabBarController
            }, completion: nil)
            window.makeKeyAndVisible()
        }
    }
    
    // MARK: Selector
    @objc func showTabBar() {
        UserDefaultsManager.totalTimesLaunching = true
        animateButton {
            self.performTransitionToTabBar()
        }
    }
    
    @objc func touchDown() {
        UIView.animate(withDuration: 0.1) {
            self.tapButton.transform = CGAffineTransform(scaleX: 1.06, y: 1.06)
        }
    }
    
    @objc func touchUpOutside() {
        UIView.animate(withDuration: 0.1) {
            self.tapButton.transform = .identity
        }
    }
}

// MARK: - Setup Views and Constraints
private extension OnboardingSecond {
    func setupViews() {
        view.addSubviews(backgroundImage, labelOnboarding, tapButton)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundImage.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundImage.rightAnchor.constraint(equalTo: view.rightAnchor),
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            labelOnboarding.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            labelOnboarding.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            labelOnboarding.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            labelOnboarding.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 70),
            
            tapButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            tapButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            tapButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tapButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -84),
            tapButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])
    }
}
