//
//  Category.swift
//  TodoApp
//
//  Created by Olga Melnyk on 24.09.2021.
//

import Foundation
import RealmSwift

class Category: Object {
    @Persisted var name: String = ""
    @Persisted var color: String = ""
    
    @Persisted var items: List<Item>
}
