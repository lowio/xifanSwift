//
//  Array2D.swift
//  xlib
//
//  Created by 173 on 15/9/10.
//  Copyright (c) 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: properties
struct XArray2D<T> {
    
    //source
    var source:[T];
    
    //orient
    private var orient:XArray2D_Orient;
    
    /*
    |0|1|2|
    |3|4|5|
    |6|7|8|
    |9|
    **/
    init(columns:Int)
    {
        self.orient = .Column(columns);
        self.source = [];
    }
    
    /*
    |0|3|6|9|
    |1|4|7|
    |2|5|8|
    **/
    init(rows:Int)
    {
        orient = .Row(rows);
        self.source = [];
    }
    
    //elements count
    var count:Int{
        return source.count;
    }
    
    //columns
    var columns:Int{
        switch orient
        {
        case .Column(let c):
            return c;
        case .Row(let r):
            return (count-1)/r + 1;
        }
    }
    
    //rows
    var rows:Int{
        switch orient
        {
        case .Column(let c):
            return (count - 1)/c + 1;
        case .Row(let r):
            return r;
        }
    }
    
    //contains element at (column, row)
    func containsElementAt(column:Int, row:Int) -> Bool
    {
        let index = self.orient.getIndex(column, row: row);
        return self.containsElementAt(index);
    }
    
    //append
    mutating func append(element:T)
    {
        self.source.append(element);
    }
    
    //update
    mutating func update(element:T, atColumn c:Int, atRow r:Int) -> Bool
    {
        let index = getIndex(c, row: r);
        if index < 0 { return false; }
        self[index] = element;
        return true;
    }
    
    //get element by (column, row)
    subscript(column:Int, row:Int) -> T?{
        let index = getIndex(column, row: row);
        if !containsElementAt(index) { return nil; }
        return self[index];
    }
}

//MARK: subscript
private extension XArray2D
{
    //contains element at index
    func containsElementAt(index:Int) -> Bool
    {
        return index >= 0 && index < self.count;
    }
    
    //get element index
    func getIndex(column:Int, row:Int) -> Int
    {
        let index = self.orient.getIndex(column, row: row);
        return self.containsElementAt(index) ? index : -1;
    }
    
    //subscript element by index
    subscript(index:Int) -> T {
        set{
            self.source[index] = newValue;
        }
        get{
            return self.source[index];
        }
    }
}

//MARK: Printable
extension XArray2D: Printable
{
    var description:String{
        let rs = self.rows;
        let cs = self.columns;
        let len = self.count;
        var desc:String = "";
        for r in 0..<rs
        {
            for c in 0..<cs
            {
                var s:String;
                if let e = self[c, r]
                {
                    s = String(stringInterpolationSegment: e);
                }
                else
                {
                    s = "nil";
                }
                desc += "\(s),";
            }
            desc += "\n";
        }
        return desc;
    }
}

//XArray2D_Orient
//case .Column: 0,1,2,3,4,5.......n;
//case .Row:0,row, 2*row, 3*row.....n*row;
private enum XArray2D_Orient
{
    case Column(Int)
    case Row(Int)
    
    //get position (column, row)
    func position(index:Int) -> (Int, Int)
    {
        switch self
        {
        case .Column(let c):
            return (index%c, index/c);
        case .Row(let r):
            return (index/r, index%r);
        }
    }
    
    //get index;
    func getIndex(column:Int, row:Int) -> Int
    {
        if column < 0 || row < 0{return -1;}
        switch self
        {
        case .Column(let c):
            return column < c ? row * c + column : -1;
        case .Row(let r):
            return row < r ? column * r + row : -1;
        }
    }
    
    var value:Int{
        switch self
        {
        case .Column(let c):
            return c;
        case .Row(let r):
            return r;
        }
    }
}