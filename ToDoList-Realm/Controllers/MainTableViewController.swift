//
//  MainTableViewController.swift
//  ToDoList-Realm
//
//  Created by Dimas Wisodewo on 26/02/23.
//

import UIKit

class MainTableViewController: UITableViewController {

    private var addBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
    private let editBarButton = UIBarButtonItem(image: UIImage(systemName: "pencil"), style: .plain, target: nil, action: nil)
    private let deleteBarButton = UIBarButtonItem(barButtonSystemItem: .trash, target: nil, action: nil)
    
    lazy private var pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 300)
        return picker
    }()
    
    private var titleTextField = UITextField()
    private var categoryTextField = UITextField()
    
    private var isDelete = false
    private var isEdit = false
    
    private var selectedCategory: Category = Category.uncategorized
    
    private var itemArray: [Data] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureNavigationItem()
        configureBarButtonAction()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        populateDummyData()
    }
    
    private func configureTableView() {
        tableView.register(DataTableViewCell.self, forCellReuseIdentifier: "ToDoItemCell")
    }
    
    private func configureNavigationItem() {
        navigationItem.title = "To-Do List"
        navigationItem.setRightBarButtonItems([addBarButton], animated: true)
        navigationItem.setLeftBarButtonItems([deleteBarButton, editBarButton], animated: true)
    }
    
    private func configureBarButtonAction() {
        addBarButton.target = self
        addBarButton.action = #selector(addButtonPressed)
        editBarButton.target = self
        editBarButton.action = #selector(editButtonPressed)
        deleteBarButton.target = self
        deleteBarButton.action = #selector(deleteButtonPressed)
    }
    
    @objc private func addButtonPressed() {
        
        // Create a new alert
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        // Add alert action
        let addAction = UIAlertAction(title: "Add Item", style: .default) { action in
            
            // Title text field validation
            guard let safeTitleTextFieldValue = self.titleTextField.text else { return }
            if safeTitleTextFieldValue.isEmpty { return }
            
            // Category text field validation
            guard let safeCategoryTextFieldValue = self.categoryTextField.text else { return }
            if safeCategoryTextFieldValue.isEmpty { self.selectedCategory = Category.uncategorized }
            
            let newItemData = Data(name: safeTitleTextFieldValue, category: self.selectedCategory)
            self.itemArray.append(newItemData)
            self.tableView.reloadData()
        }
        
        // Add title text field
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "What are you planning to do?"
            self.titleTextField = alertTextField
        }
        
        // Add category text field
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Category"
            alertTextField.inputView = self.pickerView // Show the picker when tapping the category input field
            self.categoryTextField = alertTextField
        }
        
        // Add action to the alert
        alert.addAction(addAction)
        
        // Present the alert
        present(alert, animated: true, completion: nil)
    }
    
    @objc func editButtonPressed() {
        // Toggle edit mode
        isEdit = !isEdit
        isDelete = false
        
        deleteBarButton.isEnabled = !isEdit
        addBarButton.isEnabled = !isEdit
    }
    
    @objc func deleteButtonPressed() {
        // Toggle delete mode
        isDelete = !isDelete
        isEdit = false
        
        editBarButton.isEnabled = !isDelete
        addBarButton.isEnabled = !isDelete
    }
    
    // Create dummy data
    private func populateDummyData() {
        for i in 0...Category.allCases.count - 1 {
            let data = Data(name: "Data \(i)", category: Category.allCases[i])
            itemArray.append(data)
        }
    }
    
    //MARK: UITableView Delegate & DataSource
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Use reusable cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath) as! DataTableViewCell
        cell.data = itemArray[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let cell = tableView.cellForRow(at: indexPath) as? DataTableViewCell {
            if isEdit {
                editCell(cellAtRow: indexPath.row)
            } else if isDelete {
                deleteCell(cellAtRow: indexPath.row)
            } else {
                toggleCheckmark(cell: cell)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
}

extension MainTableViewController: DataTableViewCellDelegate {
    
    func toggleCheckmark(cell: DataTableViewCell) {
        guard let safeData = cell.data else { return }
        let isChecked = safeData.isChecked
        cell.data?.isChecked = !isChecked
        cell.getCheckmarkImage.isHidden = isChecked
    }
    
    func editCell(cellAtRow: Int) {
                
        // Create a new alert
        let alert = UIAlertController(title: "Edit Item", message: "", preferredStyle: .alert)
        
        // Add alert action
        let applyAction = UIAlertAction(title: "Apply", style: .default) { action in
            
            // Title text field validation
            guard let safeTitleTextFieldValue = self.titleTextField.text else { return }
            if safeTitleTextFieldValue.isEmpty { return }
            
            // Category text field validation
            guard let safeCategoryTextFieldValue = self.categoryTextField.text else { return }
            self.selectedCategory = Category(rawValue: safeCategoryTextFieldValue) ?? Category.uncategorized
            
            let newItemData = Data(name: safeTitleTextFieldValue, category: self.selectedCategory, isChecked: self.itemArray[cellAtRow].isChecked)
            self.itemArray[cellAtRow] = newItemData
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        // Add title text field
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "What are you planning to do?"
            alertTextField.text = self.itemArray[cellAtRow].name
            self.titleTextField = alertTextField
        }
        
        // Add category text field
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Category"
            alertTextField.text = self.itemArray[cellAtRow].category.rawValue
            alertTextField.inputView = self.pickerView // Show the picker when tapping the category input field
            self.categoryTextField = alertTextField
        }
        
        // Add action to the alert
        alert.addAction(applyAction)
        alert.addAction(cancelAction)
        
        // Present the alert
        present(alert, animated: true, completion: nil)
    }
    
    func deleteCell(cellAtRow: Int) {
        
        // Create a new alert
        let alert = UIAlertController(title: "Delete Item?", message: "\(itemArray[cellAtRow].name)\n\(itemArray[cellAtRow].category.rawValue)", preferredStyle: .alert)
        
        // Add alert action
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { action in
            self.itemArray.remove(at: cellAtRow)
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        // Add action to the alert
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        // Present the alert
        present(alert, animated: true, completion: nil)
    }
}

extension MainTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Category.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Category.allCases[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = Category.allCases[row] // Change the selected category
        categoryTextField.text = selectedCategory.rawValue // Change the categoryTextField text
    }
}
