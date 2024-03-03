//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Андрей Мерзликин on 03.03.2024.
//

import UIKit

final class CategoryViewController: UIViewController {
    
    private let cellReuseIdentifier = "HabitCategoryViewController"
    private var trackerCategoryStore = TrackerCategoryStore()
    private(set) var viewModel: CategoryViewModel = CategoryViewModel.shared
    
    private let categotyHeader: UILabel = {
        let header = UILabel()
        header.text = "Категория"
        header.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        header.textColor = .ypBlackDay
        return header
    }()
    
    private let emptyCategoryPlaceholder: UIImageView = {
        let emptyTrackersImage = UIImageView()
        emptyTrackersImage.image = UIImage(named: "Blank_page_image_placeholder")
        return emptyTrackersImage
    }()
    
    private let emptyCategoryText: UILabel = {
        let emptyTrackersText = UILabel()
        emptyTrackersText.text = "Привычки и события можно\nобъединить по смыслу"
        emptyTrackersText.textColor = .ypBlackDay
        emptyTrackersText.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        emptyTrackersText.numberOfLines = 2
        emptyTrackersText.textAlignment = .center
        
        return emptyTrackersText
    }()
    
    private lazy var addCategory: UIButton = {
        let addCategoryButton = UIButton(type: .custom)
        addCategoryButton.setTitle("Добавить категорию", for: .normal)
        addCategoryButton.setTitleColor(.ypWhiteDay, for: .normal)
        addCategoryButton.backgroundColor = .ypBlackDay
        addCategoryButton.layer.cornerRadius = 16
        addCategoryButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        addCategoryButton.addTarget(self, action: #selector(addCategoryTapped), for: .touchUpInside)
        return addCategoryButton
    }()
    
    private let categoriesTableView: UITableView = {
        let categoriesTableView = UITableView()
        categoriesTableView.separatorStyle = .none
        categoriesTableView.layer.cornerRadius = 16
        categoriesTableView.isHidden = true
        return categoriesTableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhiteDay
        setupTrackersTableView()
        setupConstraints()
    }
    
    private func setupTrackersTableView() {
        categoriesTableView.delegate = self
        categoriesTableView.dataSource = self
        categoriesTableView.register(CategoryCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        checkEmptyCategoriesScreen()
    }
    private func checkEmptyCategoriesScreen() {
        let isEmptyCategories = viewModel.categories.isEmpty
        categoriesTableView.isHidden = !isEmptyCategories
        emptyCategoryPlaceholder.isHidden = isEmptyCategories
        emptyCategoryText.isHidden = isEmptyCategories
    }
    
    private func setupConstraints() {
        [categotyHeader, emptyCategoryPlaceholder,
         emptyCategoryText, addCategory, categoriesTableView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: view.topAnchor),
            view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            categotyHeader.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
            categotyHeader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            categoriesTableView.topAnchor.constraint(equalTo: categotyHeader.bottomAnchor, constant: 38),
            categoriesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoriesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoriesTableView.bottomAnchor.constraint(equalTo: addCategory.topAnchor, constant: -16),
            emptyCategoryPlaceholder.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyCategoryPlaceholder.topAnchor.constraint(equalTo: categotyHeader.bottomAnchor, constant: 246),
            emptyCategoryPlaceholder.heightAnchor.constraint(equalToConstant: 80),
            emptyCategoryPlaceholder.widthAnchor.constraint(equalToConstant: 80),
            emptyCategoryText.centerXAnchor.constraint(equalTo: emptyCategoryPlaceholder.centerXAnchor),
            emptyCategoryText.topAnchor.constraint(equalTo: emptyCategoryPlaceholder.bottomAnchor, constant: 8),
            addCategory.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            addCategory.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategory.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategory.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func addCategoryTapped() {
        let сreateCategoryViewController = CreateCategoryViewController()
        сreateCategoryViewController.categoryViewController = self
        present(сreateCategoryViewController, animated: true, completion: nil)
    }
}

// MARK: - CategoryActions
extension CategoryViewController: CategoryActions {
    func appendCategory(category: String) {
        viewModel.addCategory(category)
        categoriesTableView.isHidden = false
        emptyCategoryPlaceholder.isHidden = true
        emptyCategoryText.isHidden = true
    }
    
    func updateCategory(category:TrackerCategory?, header: String) {
        viewModel.updateCategory(category: category, header: header)
    }
    
    func reload() {
        self.categoriesTableView.reloadData()
    }
}

// MARK: - UITableViewDelegate
extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < viewModel.categories.count else {
            return
        }
        
        if let cell = tableView.cellForRow(at: indexPath) as? CategoryCell {
            cell.done(with: UIImage(named: "Checkmark") ?? UIImage())
            viewModel.selectCategory(indexPath.row)
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let separatorInset: CGFloat = 16
        let separatorWidth = tableView.bounds.width - separatorInset * 2
        let separatorHeight: CGFloat = 1.0
        let separatorX = separatorInset
        let separatorY = cell.frame.height - separatorHeight
        
        let isLastCell = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        
        if !isLastCell {
            let separatorView = UIView(frame: CGRect(x: separatorX, y: separatorY, width: separatorWidth, height: separatorHeight))
            separatorView.backgroundColor = .ypGray
            cell.addSubview(separatorView)
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let category = self.viewModel.categories[indexPath.row]
        
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = self.createEditAction(for: category)
            let deleteAction = self.createDeleteAction(for: category)
            
            let actions = [editAction, deleteAction]
            return UIMenu(title: "", children: actions)
        }
        
        return configuration
    }
    
    // Создание действия редактирования
    private func createEditAction(for category: TrackerCategory) -> UIAction {
        return UIAction(title: "Редактировать") { [weak self] _ in
            guard let self = self else { return }
            
            self.updateCategory(category: category, header: "Редактирование категории")
        }
    }
    
    // Создание действия удаления
    private func createDeleteAction(for category: TrackerCategory) -> UIAction {
        return UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            self.showDeleteCategoryAlert(category)
        }
    }
    
    // Отображение алерта удаления категории
    private func showDeleteCategoryAlert(_ category: TrackerCategory) {
        let alertController = UIAlertController(title: nil, message: "Эта категория точно не нужна?", preferredStyle: .actionSheet)
        let deleteConfirmationAction = UIAlertAction(title: "Удалить", style: .destructive) { _ in
            try? self.trackerCategoryStore.deleteCategory(category)
            self.checkEmptyCategoriesScreen()
            self.categoriesTableView.reloadData()
        }
        alertController.addAction(deleteConfirmationAction)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? CategoryCell else { return UITableViewCell() }
        
        if indexPath.row < viewModel.categories.count {
            let category = viewModel.categories[indexPath.row]
            cell.update(with: category.title)
            
            let isLastCell = indexPath.row == viewModel.categories.count - 1
            if isLastCell {
                cell.layer.cornerRadius = 16
                cell.layer.masksToBounds = true
                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            } else {
                cell.layer.cornerRadius = 0
                cell.layer.masksToBounds = false
            }
        }
        return cell
    }
}
