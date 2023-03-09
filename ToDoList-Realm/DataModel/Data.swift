//
//  Data.swift
//  ToDoList-Realm
//
//  Created by Dimas Wisodewo on 26/02/23.
//

import Foundation
import RealmSwift

class Data: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var category: String = Category.uncategorized.rawValue
    @objc dynamic var isChecked: Bool = false
    
    override init() {
        super.init()
    }
    
    init(name: String, category: Category = Category.uncategorized, isChecked: Bool = false) {
        self.name = name
        self.category = category.rawValue
        self.isChecked = isChecked
    }
}
