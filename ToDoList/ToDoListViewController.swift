//
//  ToDoListViewController.swift
//  ToDoList
//
/*
 MIT License
 
 Copyright (c) 2018 Gwinyai Nyatsoka
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit

protocol ToDoListDelegate: class {
    
    func update(task: ToDoItemModel, index: Int)

    //func addNewToDoItem( newItem: ToDoItemModel)
}

class ToDoListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    var toDoItems: [ToDoItemModel] = [ToDoItemModel] ()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.delegate = self
        
        tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
        
        title = "To Do List"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTapped))
        
        let testItem = ToDoItemModel(name: "Test Item", details: "Test Detail", completionDate: Date())
        
        self.toDoItems.append(testItem)
        
        let testItem2 = ToDoItemModel(name: "Test Item2", details: "Test Detail2", completionDate: Date())
        
        self.toDoItems.append(testItem2)
        
        NotificationCenter.default.addObserver(self, selector: #selector(addNewTask(_ :)), name: NSNotification.Name.init("com.todolistapp.addtask"), object: nil)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tableView.setEditing(false, animated: false)
    }
    
    @objc func addNewTask(_ notification: NSNotification){
        
        var toDoItem: ToDoItemModel!
        
        if let task = notification.object as? ToDoItemModel {
            
            toDoItem = task
            
        }else if let taskDict = notification.userInfo as NSDictionary? {
            
            guard let task = taskDict["Task"] as? ToDoItemModel else {return}
            
            toDoItem = task
            
        } else {
            
            return
            
        }
        
        toDoItems.append(toDoItem)
        
        toDoItems.sort(by: {$0.completionDate < $1.completionDate})
        
        tableView.reloadData()
        
    }
    
    @objc func addTapped(){
        
        performSegue(withIdentifier: "AddTaskSegue", sender: nil)
        
    }
    
    @objc func editTapped() {
        
        tableView.setEditing(!tableView.isEditing, animated: true)
        
        if tableView.isEditing {
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editTapped))
        } else {
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTapped))
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delelete") { (action, indexPath) in
            
            self.toDoItems.remove(at: indexPath.row)
            
            self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            
        }
        
        return [delete]
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedItem = toDoItems[indexPath.row]
        
        let toDoTuple = (indexPath.row, selectedItem)
        
        performSegue(withIdentifier: "TaskDetailsSegue", sender: toDoTuple)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return toDoItems.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let toDoItem = toDoItems[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItem")!
        
        cell.textLabel?.text = toDoItem.name
        
        cell.detailTextLabel?.text = toDoItem.isComplete ? "Complete" : "Incomplete"
        
        return cell
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "TaskDetailsSegue" {
            
            guard let destinationVC = segue.destination as? ToDoDetailsViewController else {return}
            
            guard let toDoTuple = sender as? (Int, ToDoItemModel) else {return}
            
            destinationVC.toDoIndex = toDoTuple.0
            
            destinationVC.toDoItem = toDoTuple.1
            
            destinationVC.delegate = self
            
        }
        /*
        if segue.identifier == "AddTaskSegue" {
            
            guard let destinationVC = segue.destination as? AddTaskViewController else {return}
            
            destinationVC.delegate = self
            
        }
        */
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init("com.todolistapp.addtask"), object: nil)
    }
}


extension ToDoListViewController: ToDoListDelegate {
    
    func update(task: ToDoItemModel, index: Int) {
        
        toDoItems[index] = task
        
        tableView.reloadData()
        
    }
    /*
    func addNewToDoItem(newItem: ToDoItemModel) {
        
        toDoItems.append(newItem)
        print(toDoItems.count)
        
        tableView.reloadData()
        
    }
 */
}
