//
//  Data.swift
//  ToDoList-Realm
//
//  Created by Dimas Wisodewo on 26/02/23.
//

import Foundation

class Data {
    var name: String = ""
    var category: Category = Category.uncategorized
    var isChecked: Bool = false
    
    init(name: String, category: Category = Category.uncategorized, isChecked: Bool = false) {
        self.name = name
        self.category = category
        self.isChecked = isChecked
    }
}
