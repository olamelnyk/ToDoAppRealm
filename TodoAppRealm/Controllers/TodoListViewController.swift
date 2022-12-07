//
//  ViewController.swift
//  TodoApp
//
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
 

    let realm = try! Realm()
    
    var todoItems: Results<Item>?
    
    var selectedCategory : Category? {
        didSet{
           loadItems()
            
            tableView.separatorStyle = .none
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let colorHex = selectedCategory?.color {
            
            title = selectedCategory!.name
            
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist.")}
                
            if let navBarColor = UIColor(hexString: colorHex) {
                
                navBar.backgroundColor  = navBarColor // barTintColor +
                navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true) 
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
                searchBar.barTintColor = navBarColor
            }
        }
    }

   //MARK - Tableview Datasource Methods

   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {

            cell.textLabel?.text = item.title
        
            //Ternary operator ==>
            //value = condition ? valueIfTrue : valueIfFalse
        
            cell.accessoryType = item.done ? .checkmark : .none
            
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage:CGFloat(indexPath.row ) / CGFloat(todoItems!.count)){
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
        }else{
            
            cell.textLabel?.text = "No Items Added"
            
        }
        
        return cell
     }
    
    //MARK: - TableView Delegate Methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row]{
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
        
        tableView.reloadData()
        
       // let cell = tableView.cellForRow(at: indexPath)?.textLabel?.text
       // print(cell as Any)
        
       /* context.delete(itemArray[indexPath.row])
        itemArray.remove(at: indexPath.row)*/

       // todoItems[indexPath.row].done = !todoItems[indexPath.row].done
        
        /* if itemArray[indexPath.row].done == false {
            itemArray[indexPath.row].done = true
        } else {
            itemArray[indexPath.row].done = false
        }*/
        
        /* if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark{
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }*/
        
       // saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
                
    }
    
    //MARK - Add New Item
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New ToDo Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen once the user clicks the Add Item button on our UIAlert
            
            if let currentCategory = self.selectedCategory {
                
                do{
                    try self.realm.write(){
                        let newItem = Item()
                        
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new items \(error)")
                }
                
            }
     
            self.tableView.reloadData()
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    func loadItems(){
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    
   }
    
    //MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        
                    if let itemForDeletion = self.todoItems?[indexPath.row]{
                        do {
                            try self.realm.write(){
                                self.realm.delete(itemForDeletion)
                            }
                        } catch {
                            print("Error deleting category, \(error)")
                        }
                        
                        tableView.reloadData()
                    }
    }

}

//MARK: - Search bar methods

extension TodoListViewController: UISearchBarDelegate{
    
    internal func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
        
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }


}


