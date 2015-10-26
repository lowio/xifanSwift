//
//  XNode.swift
//  XCrunch
//
//  Created by 叶贤辉 on 15/4/13.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import SpriteKit

//xnode data
class XNodeData: CustomStringConvertible {
    
    //行列
    var column, row:Int;
    
    //node type
    var nodeType:XNodeType;
    
    //node display
    var sprite:SKSpriteNode?;
    
    init(column:Int, row:Int, type:XNodeType)
    {
        self.column = column;
        self.row = row;
        self.nodeType = type;
    }
    
    var description:String {
        return "type:\(nodeType), column:\(column), row:\(row)";
    }
    
}


func ==(lhs:XNodeData, rhs:XNodeData) -> Bool
{
    return lhs.row == rhs.row && lhs.column == rhs.column;
}

//可哈希
extension XNodeData: Hashable
{
    var hashValue:Int {
        return row * 10 + column;
    }
}


//xnode type
enum XNodeType:Int
{
    //xnode 类型
    case UnKnown = 0, T1, T2, T3, T4, T5, T6
    
    //sprite name 列表
    private static let spriteNames = ["Croissant", "Cupcake", "Danish", "Donut", "Macaroon", "SugarCookie"];
    
    //类型 对应的 spritename
    var spriteName:String{
        return XNodeType.spriteNames[rawValue - 1];
    }
    
    //类型 对应的 高亮 spritename
    var highLightedSpriteName:String{
        return spriteName + "-Highlighted";
    }
    
}

//打印相关
extension XNodeType:CustomStringConvertible
{
    var description: String{
        return spriteName;
    }
}

//创建相关
extension XNodeType
{
    //随即创建一个random
    static func random() -> XNodeType
    {
        return XNodeType(rawValue: Int(arc4random_uniform(6)) + 1)!;
    }
}

