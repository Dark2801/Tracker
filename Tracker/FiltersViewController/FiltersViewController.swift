//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Андрей Мерзликин on 03.03.2024.
//

import UIKit

protocol FiltersViewControllerDelegate: AnyObject {
    func filtersViewController(_ controller: FiltersViewController, didSelectFilter filter: Filters)
}

final class FiltersViewController: UIViewController {
    
    weak var delegate: FiltersViewControllerDelegate?
    var selectedFilters: Filters?
    
    //MARK: - Layout variables
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("filter.title", comment: "Filters")
        label.textColor = .ypBlackDay
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 75
        tableView.layer.cornerRadius = 16
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        
        return tableView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhiteDay
        tableView.register(FiltersCell.self, forCellReuseIdentifier: FiltersCell.reuseIdentifier)
        
        addSubViews()
        applyConstraints()
    }
    
    // MARK: - Private Methods
    
    private func addSubViews() {
        [titleLabel, tableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 21),
            
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(Filters.allCases.count * 75)),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}

//MARK: - UITableViewDataSource

extension FiltersViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Filters.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FiltersCell.reuseIdentifier, for: indexPath)
        
        guard let filtersCell = cell as? FiltersCell else {
            return UITableViewCell()
        }
        
        filtersCell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        if indexPath.row == Filters.allCases.count - 1 {
            filtersCell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
        }
        
        let currentFilters = Filters.allCases[indexPath.row]
        let isSelected = selectedFilters == currentFilters
        filtersCell.configureCell(filter: currentFilters, isSelected: isSelected)
        
        return filtersCell
    }
}

//MARK: - UITableViewDelegate

extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.filtersViewController(self, didSelectFilter: Filters.allCases[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
        dismiss(animated: true)
    }
}
