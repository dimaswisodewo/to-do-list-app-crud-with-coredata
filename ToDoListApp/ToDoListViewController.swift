//
//  ViewController.swift
//  ToDoListApp
//
//  Created by Dimas Wisodewo on 17/01/23.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {

    var itemArray: [ItemData] = []
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    var isEdit = false;
    var isDelete = false;
    
    // Get context for saving data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Print the database path to the debug console
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        // Fetch data
        loadData()
    }

    //MARK - TableView DataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Use reusable cell by entering the identifier we specified earlier
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        // Set item text
        cell.textLabel?.text = itemArray[indexPath.row].title
        
        // Set checkmark
        cell.accessoryType = itemArray[indexPath.row].isChecked ? .checkmark : .none
        
        return cell
    }
    
    //MARK - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Deselect row to remove the grey highlight
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let cell = tableView.cellForRow(at: indexPath) {
            
            if isEdit {
                // Edit data
                // Variable to store the alert text fields value
                var textField = UITextField()
                
                // Create a new alert
                let alert = UIAlertController(title: "Edit Item", message: "", preferredStyle: .alert)
                
                // Add alert action
                let addAction = UIAlertAction(title: "Edit Item", style: .default) { action in
                    // Will be called when user click the Add Item button on our UIAlert
                    
                    // Alert text field validation
                    guard let safeTextFieldValue = textField.text else { return }
                    if safeTextFieldValue.isEmpty { return }
                    
                    // Update data
                    self.updateData(index: indexPath.row, newTitle: safeTextFieldValue)
                    
                    // Reload the Table View
                    self.tableView.reloadData()
                }
                
                // Add a text field within the alert
                alert.addTextField { alertTextField in
                    alertTextField.placeholder = "What are you planning to do?"
                    alertTextField.text = self.itemArray[indexPath.row].title
                    textField = alertTextField
                }
                
                // Add action to the alert
                alert.addAction(addAction)
                
                // Present the alert
                present(alert, animated: true, completion: nil)
            } else if isDelete {
                // Delete from database first then delete inside itemArray
                removeData(itemData: itemArray[indexPath.row])
                itemArray.remove(at: indexPath.row)
                
                // Reload the Table View
                tableView.reloadData()
            } else {
                // Toggle checkmark
                cell.accessoryType = cell.accessoryType == .none ? .checkmark : .none
                
                // Update the data inside itemArray
                itemArray[indexPath.row].isChecked = cell.accessoryType == .checkmark
                
                // Save data
                saveData()
            }
            
        }
        
    }
    
    //MARK - Add New To-Do Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        // Variable to store the alert text fields value
        var textField = UITextField()
        
        // Create a new alert
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        // Add alert action
        let addAction = UIAlertAction(title: "Add Item", style: .default) { action in
            // Will be called when user click the Add Item button on our UIAlert
            
            // Alert text field validation
            guard let safeTextFieldValue = textField.text else { return }
            if safeTextFieldValue.isEmpty { return }
            
            // Create new ItemData
            let newItem = ItemData(context: self.context)
            newItem.title = safeTextFieldValue
            newItem.isChecked = false
            
            // Add to array
            self.itemArray.append(newItem)
                
            // Save data into persistent container
            self.saveData()
            
            // Reload the Table View
            self.tableView.reloadData()
        }
        
        // Add a text field within the alert
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "What are you planning to do?"
            textField = alertTextField
        }
        
        // Add action to the alert
        alert.addAction(addAction)
        
        // Present the alert
        present(alert, animated: true, completion: nil)
    }
    
    //MARK - Delete checked data
    
    @IBAction func deleteButtonPressed(_ sender: UIBarButtonItem) {
        // Toggle the delete button and edit button
        isDelete = !isDelete
        isEdit = false
        
        editButton.isEnabled = !isDelete
        addButton.isEnabled = !isDelete
    }
    
    //MARK - Edit data
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        // Toggle the delete button and edit button
        isEdit = !isEdit
        isDelete = false
        
        deleteButton.isEnabled = !isEdit
        addButton.isEnabled = !isEdit
    }
    
    // Save data
    private func saveData() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error in saving data: \(error)")
            }
        }
    }
    
    // Fetch data
    private func loadData() {
        let request: NSFetchRequest<ItemData> = ItemData.fetchRequest()
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data: \(error)")
        }
    }
    
    // Update data
    private func updateData(index: Int, newTitle: String) {
        // Backup old title
        let oldTitle = itemArray[index].title
        
        do {
            itemArray[index].title = newTitle
            try context.save()
        } catch {
            itemArray[index].title = oldTitle
            print("Error in saving data: \(error)")
        }
    }
    
    // Delete data
    private func removeData(itemData: ItemData) {
        context.delete(itemData)
        saveData()
    }
}

