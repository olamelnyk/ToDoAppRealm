//
//  CategoryViewController.swift
//  TodoApp
//
//  Created by Olga Melnyk on 07.07.2021.
//
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()

    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        loadCategories()
        
        tableView.separatorStyle = .none

    }
    
    override func viewWillAppear(_ animated: Bool) {
            
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation controller does not exist.")
        }
          
        let navBarColor = UIColor(hexString: "1D9BF6")
        navBar.backgroundColor = navBarColor  // barTintColor + backgroundColor
        navBar.tintColor = ContrastColorOf(navBarColor!, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor!, returnFlat: true)]
                
    }
    
    
    //MARK: - TableView Datasource Methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
         return categories?.count ?? 1
        
     }
    
     
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categories?[indexPath.row] {
 
            cell.textLabel?.text = category.name
            
            guard let categoryColor = UIColor(hexString: category.color) else {fatalError()}
            
            cell.backgroundColor =  UIColor(hexString: category.color)
            cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
            
            
            
        }
        return cell
        
      }
 
    
    //MARK: - TableView Delegate Methods

     override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
        
     }
 
    override func  prepare(for segue: UIStoryboardSegue, sender: Any?) {

        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    
    //MARK: - Add New Item
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New ToDo Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            //what will happen once the user clicks the Add Item button on our UIAlert
                                    
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat().hexValue()
            
            self.save(category: newCategory)
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }


    //MARK: - Data Manipulation Methods
    
    func save(category: Category){
        do{
            try realm.write(){
                realm.add(category)
            }
        } catch {
            print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadCategories(){
        
        categories = realm.objects(Category.self)

        self.tableView.reloadData()
    
   }
    
    //MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
                    if let categoryForDeletion = self.categories?[indexPath.row]{
                        do {
                            try self.realm.write(){
                                self.realm.delete(categoryForDeletion)
                            }
                        } catch {
                            print("Error deleting category, \(error)")
                        }
                        
                        tableView.reloadData()
                    } 
    }
}
