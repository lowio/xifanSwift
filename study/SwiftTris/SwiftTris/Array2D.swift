//
//  Array2D.swift
//  SwiftTris
//
//  Created by 叶贤辉 on 15/1/28.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import Foundation

//声明一个范型T
class Array2D<T>{
    
    var columns:Int
    var rows:Int
    
    var storage:[Int:[Int:T]] = [:]
    
    init(columns:Int, rows:Int)
    {
        self.columns = columns
        self.rows = rows
    }
    
    subscript(column:Int, row:Int) -> T?
    {
        get{
            return storage[row]?[column]
        }
        
        set{
            if let dic = storage[row]
            {
                storage[row]?[column] = newValue
            }
            else
            {
                storage[row] = [:]
                storage[row]![column] = newValue
            }
        }
    }
    
    //获取指定行数的nods
    func getNodesByRow(row:Int) -> [Int:T]?
    {
        if let d = storage[row]
        {
            return d
        }
        else
        {
            return nil
        }
    }
}