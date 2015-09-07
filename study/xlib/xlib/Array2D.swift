//
//  Array2D.swift
//  Threes!
//
//  Created by 叶贤辉 on 15/3/4.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import Foundation

//二维数组
struct Array2D<T>{
    
    //二维数组
    var a2d:Array<T?>
    
    //总个数，行，列
    let count, columns, rows:Int
    
    init(columns:Int, rows:Int)
    {
        self.columns = columns
        self.rows = rows
        self.count = columns * rows
        a2d = Array<T?>(count: self.count, repeatedValue: nil)
    }
    
    //二维数组副本
    private var carbon:Array<T?>?
    
    //制作副本 标记为失效，用于回滚
    mutating func invalidate()
    {
        carbon = a2d
    }
    
    //对数组的操作生效 清除副本
    mutating func validate()
    {
        carbon = nil
    }
    
    //回滚到invalidate执行时的状态
    mutating func recover()
    {
        if carbon == nil
        {
            return
        }
        self.a2d = carbon!
        carbon = nil
    }
}

//扩展下标 以及下标转换
extension Array2D
{
    //指定行列的item
    subscript(column:Int, row:Int) -> T?{
        get{
            return self[convert(column, row: row)]
        }
        
        set{
            self[convert(column, row: row)] = newValue
        }
    }
    
    //指定行列计算的值所对应的 item
    subscript(value:Int) -> T?{
        get{
            if !has(value)
            {
                return nil
            }
            return a2d[value]
        }
        
        set{
            if !has(value)
            {
                return
            }
            a2d[value] = newValue
        }
    }
    
    //指定位置是否含有项目
    func has(column:Int, row:Int) -> Bool
    {
        let value = convert(column, row: row)
        return has(value)
    }
    
    //指定位置是否含有项目
    func has(value:Int) -> Bool
    {
        return value >= 0 && value < count
    }
    
    //value 转换成 （列，行）
    func convert(value2Position v:Int) -> (Int, Int)
    {
        let r:Int = v/columns
        let c = v % columns
        return (c, r)
    }
    
    //行列转换成value
    func convert(column:Int, row:Int) -> Int
    {
        return row * columns + column
    }
}

//描述相关
extension Array2D:Printable
{
    var description: String {
        var desc = "=====Array2D node====\n"
        for r in 0..<rows
        {
            for c in 0..<columns
            {
                desc += self[c, r] == nil ? " x":" o"
            }
            desc += "\n"
        }
        return desc
    }
}