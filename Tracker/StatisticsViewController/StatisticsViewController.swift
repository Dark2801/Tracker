//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Андрей Мерзликин on 05.03.2024.
//

import UIKit

final class StatisticsViewController: UIViewController {
    
    let cellReuseIdentifier = "StatisticViewController"
    let trackersViewController: TrackersViewController
    
    init(trackersViewController: TrackersViewController) {
        self.trackersViewController = trackersViewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        return nil
    }
    
    private let header: UILabel = {
        let header = UILabel()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.text = NSLocalizedString("statistic.title", comment: "")
        header.textColor = .ypBlackDay
        header.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        return header
    }()
    
    private let emptyStatistic: UIImageView = {
        let emptySearch = UIImageView()
        emptySearch.translatesAutoresizingMaskIntoConstraints = false
        emptySearch.image = UIImage(named: "Statistic_not_found")
        return emptySearch
    }()
    
    private let emptyStatisticText: UILabel = {
        let emptySearchText = UILabel()
        emptySearchText.translatesAutoresizingMaskIntoConstraints = false
        emptySearchText.text = "Анализировать пока нечего"
        emptySearchText.textColor = .ypBlackDay
        emptySearchText.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return emptySearchText
    }()
    
    private let statisticTableView: UITableView = {
        let statisticTableView = UITableView()
        statisticTableView.separatorStyle = .none
        statisticTableView.layer.cornerRadius = 16
        statisticTableView.translatesAutoresizingMaskIntoConstraints = false
        return statisticTableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhiteDay
        addSubviews()
        
        statisticTableView.backgroundColor = .ypWhiteDay
        statisticTableView.delegate = self
        statisticTableView.dataSource = self
        statisticTableView.register(StatisticsCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        statisticTableView.reloadData()
        
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            header.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            emptyStatistic.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStatistic.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 246),
            emptyStatistic.heightAnchor.constraint(equalToConstant: 80),
            emptyStatistic.widthAnchor.constraint(equalToConstant: 80),
            emptyStatisticText.centerXAnchor.constraint(equalTo: emptyStatistic.centerXAnchor),
            emptyStatisticText.topAnchor.constraint(equalTo: emptyStatistic.bottomAnchor, constant: 8),
            statisticTableView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 77),
            statisticTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            statisticTableView.heightAnchor.constraint(equalToConstant: 500)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        statisticTableView.reloadData()
        showPlaceholder()
    }
    
    private func addSubviews() {
        view.addSubview(header)
        view.addSubview(emptyStatistic)
        view.addSubview(emptyStatisticText)
        view.addSubview(statisticTableView)
    }
    
    private func showPlaceholder() {
        let hasCompletedTrackers = trackersViewController.completedTrackers.count > 0
        emptyStatistic.isHidden = hasCompletedTrackers
        emptyStatisticText.isHidden = hasCompletedTrackers
        statisticTableView.isHidden = !hasCompletedTrackers
    }
}

// MARK: - UITableViewDelegate
extension StatisticsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 102
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12
    }
}

// MARK: - UITableViewDataSource
extension StatisticsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? StatisticsCell else { return UITableViewCell() }
        
        var title = ""
        
        switch indexPath.row {
        case 0:
            title = "Лучший период"
        case 1:
            title = "Идеальные дни"
        case 2:
            title = "Трекеров завершено"
        case 3:
            title = "Среднее значение"
        default:
            break
        }
        
        var count = ""
        
        switch indexPath.row {
        case 0:
            count = "0"
        case 1:
            count = "0"
        case 2:
            count = "\(trackersViewController.completedTrackers.count)"
        case 3:
            count = "0"
        default:
            break
        }
        
        cell.update(with: title, count: count)
        cell.selectionStyle = .none
        cell.isUserInteractionEnabled = false
        
        return cell
    }
}
