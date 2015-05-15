//
//  AddToDoItemViewController.swift
//  todoList
//
//  Created by 173 on 15/4/29.
//  Copyright (c) 2015年 173. All rights reserved.
//

import UIKit

class AddToDoItemViewController: UIViewController {
    
    
    @IBOutlet weak var saveBtn: UIBarButtonItem!

    @IBOutlet weak var textInput: UITextField!
    
    var newCellData:TodoItemCell?;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //准备返回目标viewcontrol之前
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        newCellData = nil;
        if let btn = sender as? UIBarButtonItem where btn == saveBtn && count(textInput.text) >= 0
        {
            newCellData = TodoItemCell(itemName: textInput.text);
        }
        
    }


}
