//
//  MainTableViewController.swift
//  ToDoList-Realm
//
//  Created by Dimas Wisodewo on 26/02/23.
//

import UIKit

class MainTableViewController: UITableViewController {

    private let addBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: MainTableViewController.self, action: nil)
    private let editBarButton = UIBarButtonItem(image: UIImage(systemName: "pencil"), style: .plain, target: MainTableViewController.self, action: nil)
    private let deleteBarButton = UIBarButtonItem(barButtonSystemItem: .trash, target: MainTableViewController.self, action: nil)
    
    private var itemArray: [Data] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationItem()
        configureTableView()
        
        populateDummyData()
    }
    
    private func configureTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80.0
        tableView.register(DataTableViewCell.self, forCellReuseIdentifier: "ToDoItemCell")
    }
    
    private func configureNavigationItem() {
        navigationItem.title = "To-Do List"
        navigationItem.setRightBarButtonItems([addBarButton], animated: true)
        navigationItem.setLeftBarButtonItems([deleteBarButton, editBarButton], animated: true)
    }
    
    // Create dummy data
    private func populateDummyData() {
        for i in 0...Category.allCases.count-1 {
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
            toggleCheckmark(cell: cell)
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
}
