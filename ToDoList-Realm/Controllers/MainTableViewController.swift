//
//  MainTableViewController.swift
//  ToDoList-Realm
//
//  Created by Dimas Wisodewo on 26/02/23.
//

import UIKit
import RealmSwift
import SwipeCellKit

class MainTableViewController: UITableViewController {

    let realm = try! Realm()
    
    private var addBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
    private let editBarButton = UIBarButtonItem(image: UIImage(systemName: "pencil"), style: .plain, target: nil, action: nil)
    
    lazy private var pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 300)
        return picker
    }()
    
    private var titleTextField = UITextField()
    private var categoryTextField = UITextField()
    
    private var isEdit = false
    
    private var selectedCategory: Category = Category.uncategorized
    
    private var itemArray: Results<Data>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureNavigationItem()
        configureBarButtonAction()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        realmGetData() // Get realm data
        
        // Print the path to the realm file location
        print("User Realm User file location: \(realm.configuration.fileURL!.path)")
    }
    
    // Get realm data
    private func realmGetData() {
        itemArray = realm.objects(Data.self).sorted(byKeyPath: "name", ascending: true)
    }
    
    private func realmAdd(data: Data) {
        do {
            try realm.write {
                realm.add(data)
            }
        } catch {
            print("Error saving data \(error)")
        }
    }
    
    private func configureTableView() {
        tableView.register(DataTableViewCell.self, forCellReuseIdentifier: "ToDoItemCell")
    }
    
    private func configureNavigationItem() {
        navigationItem.title = "To-Do List"
        navigationItem.setRightBarButtonItems([addBarButton], animated: true)
    }
    
    private func configureBarButtonAction() {
        addBarButton.target = self
        addBarButton.action = #selector(addButtonPressed)
        editBarButton.target = self
        editBarButton.action = #selector(editButtonPressed)
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
            
            // Save data with realm
            self.realmAdd(data: newItemData)
            
            // Reload data
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
        
        addBarButton.isEnabled = !isEdit
    }
    
    //MARK: UITableView Delegate & DataSource
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Use reusable cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath) as! DataTableViewCell
        cell.data = itemArray?[indexPath.row]
        let swipeCell = cell as SwipeTableViewCell
        swipeCell.delegate = self
        return swipeCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if isEdit {
            editCell(cellAtRow: indexPath.row)
        } else {
            toggleCheckmark(indexPath: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray?.count ?? 0
    }
}

extension MainTableViewController: DataTableViewCellDelegate {
    
    func toggleCheckmark(indexPath: IndexPath) {
        
        let row = indexPath.row
        guard let isChecked = itemArray?[row].isChecked else { return }
        
        // Update data with realm
        do {
            try realm.write {
                itemArray?[row].isChecked = !isChecked

                let cell = tableView.cellForRow(at: indexPath) as! DataTableViewCell
                cell.getCheckmarkImage.isHidden = isChecked
            }
        } catch {
            print("Error in toggle checkmark: \(error)")
        }
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
            
            // Update data with realm
            do {
                try self.realm.write {
                    self.itemArray?[cellAtRow].category = self.selectedCategory.rawValue
                    self.itemArray?[cellAtRow].isChecked = self.itemArray?[cellAtRow].isChecked ?? false
                    
                    // Set name on last, otherwise the table view will sort the cell before we finish updating the data
                    self.itemArray?[cellAtRow].name = safeTitleTextFieldValue
                }
            } catch {
                print("Error edit item: \(error)")
            }
            
            // Reload data
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        // Add title text field
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "What are you planning to do?"
            alertTextField.text = self.itemArray?[cellAtRow].name
            self.titleTextField = alertTextField
        }
        
        // Add category text field
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Category"
            alertTextField.text = self.itemArray?[cellAtRow].category
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
        
        guard let cellData = itemArray?[cellAtRow] else { return }
        
        // Create a new alert
        let alert = UIAlertController(title: "Delete Item?", message: "\(cellData.name)\n\(cellData.category)", preferredStyle: .alert)
        
        // Add alert action
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { action in
            
            // Delete data with realm
            do {
                try self.realm.write {
                    self.realm.delete(cellData)
                }
            } catch {
                print("Error delete data: \(error)")
            }
            
            // Reload data
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

extension MainTableViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeCellKit.SwipeActionsOrientation) -> [SwipeCellKit.SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { [weak self] action, indexPath in
            // handle action by updating model with deletion
            self?.deleteCell(cellAtRow: indexPath.row)
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction]
    }
    
    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }

}
