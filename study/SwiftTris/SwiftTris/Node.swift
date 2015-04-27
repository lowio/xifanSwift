//
//  NodeData.swift
//  SwiftTris
//
//  Created by 叶贤辉 on 15/1/30.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import Foundation
import SpriteKit

//组成形状的节点数据
class Node:Printable
{
    //行列
    var column, row:Int
    //颜色
    var color:NodeColor
    
    //具体的现实对象
    var display:SKSpriteNode?
    
    //创建过显示对象
    var createDisplay:Bool = false
    
    //构造器
    init(column:Int, row:Int, color:NodeColor)
    {
        self.column = column
        self.row = row
        self.color = color
        display = nil
    }
    
    //便利构造器
    convenience init(column:Int, row:Int)
    {
        self.init(column: column, row: row, color: NodeColor.getRandomColor())
    }
    
    //Printable协议
    var description:String{
        return "\(color.colorName):[\(column), \(row)]"
    }
    
    //返回一个随机颜色值的制定行列的nodedata
    class func getRandomNodeData(column:Int, row:Int) -> Node
    {
        return Node(column: column, row: row)
    }

}


//节点的颜色枚举
enum NodeColor:Int, Printable{
    
    //6种颜色
    case Blue = 0, Orange, Purple, Red, Teal, Yellow
    
    //颜色名称
    var colorName:String{
        switch self
        {
        case .Blue:
            return "blue"
        case .Orange:
            return "orange"
        case .Purple:
            return "purple"
        case .Red:
            return "red"
        case .Teal:
            return "teal"
        case .Yellow:
            return "yellow"
        }
    }
    
    //Printable协议
    var description:String{
        return self.colorName
    }
    
    
    //获取随机颜色的枚举
    static func getRandomColor() -> NodeColor
    {
        let count:UInt32 = 6//颜色种类最大数量
        return NodeColor(rawValue: Int(arc4random_uniform(count)))!
    }
}