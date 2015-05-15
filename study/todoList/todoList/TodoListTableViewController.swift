//
//  TodoListTableTableViewController.swift
//  todoList
//
//  Created by 173 on 15/4/30.
//  Copyright (c) 2015年 173. All rights reserved.
//

import UIKit

class TodoListTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    var toDoItems:[TodoItemCell]!;
    
    
    @IBAction
    func unwindTodoList(segue:UIStoryboardSegue)
    {
        if let newCellData = (segue.sourceViewController as? AddToDoItemViewController)?.newCellData
        {
            toDoItems.append(newCellData);
            self.tableView.reloadData();
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        
        loadTodoItems();
        
    }
    
    //加载数据源
    private func loadTodoItems()
    {
        self.toDoItems = [];
        
        for i in 0..<5
        {
            toDoItems.append(TodoItemCell(itemName: "to-do name\(i)"));
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.toDoItems.count;
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("ListProtoTypeCell", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...
        let cellData = toDoItems[indexPath.row];
        cell.textLabel?.text = cellData.itemName;
        cell.accessoryType = cellData.isComplete ? .Checkmark : .None;
        return cell;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false);
        
        var tabCellData = self.toDoItems[indexPath.row];
        tabCellData.isComplete = !tabCellData.isComplete;
        
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None);
    }
    
//    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
//        
//    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
