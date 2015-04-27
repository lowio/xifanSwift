//
//  Array2D.swift
//  XCrunch
//
//  Created by 叶贤辉 on 15/4/13.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import Foundation


struct Array2D<T> {
    //总 行列
    var columns, rows:Int;
    
    //一维数组
    private var array:[T?];
    
    init(columns:Int, rows:Int)
    {
        self.columns = columns;
        self.rows = rows;
        self.array = Array<T?>(count: columns * rows, repeatedValue: nil);
    }
    
    subscript(column:Int, row:Int) -> T? {
        get{
            return array[columns * row + column];
        }
        
        set{
            array[columns * row + column] = newValue;
        }
    }
}