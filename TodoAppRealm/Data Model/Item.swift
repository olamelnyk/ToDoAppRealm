//
//  Item.swift
//  TodoApp
//
//  Created by Olga Melnyk on 24.09.2021.
//

import Foundation
import RealmSwift

class Item: Object {
    @Persisted var title: String = ""
    @Persisted var done: Bool = false
    @Persisted var dateCreated: Date?
    
    @Persisted(originProperty: "items") var parentCategory: LinkingObjects<Category>
}
