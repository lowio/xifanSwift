//
//  TodoItemCell.swift
//  todoList
//
//  Created by 173 on 15/5/5.
//  Copyright (c) 2015年 173. All rights reserved.
//

import Foundation


class TodoItemCell {
    
    var itemName:String;
    
    var isComplete:Bool;
    
    init(itemName:String, isComplete:Bool)
    {
        self.itemName = itemName;
        self.isComplete = isComplete;
    }
    
    convenience init(itemName:String)
    {
        self.init(itemName: itemName, isComplete: false);
    }
}