//
//  Chian.swift
//  XCrunch
//
//  Created by 叶贤辉 on 15/4/17.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import Foundation

//可消除的链子
class Chian:CustomStringConvertible, Hashable {
    
    //列表
    var nodes:[XNodeData] = [];
    
    //type
    var chianType:ChianType;
    
    init(chianType:ChianType)
    {
        self.chianType = chianType;
    }
    
    //add node
    func addNode(node:XNodeData)
    {
        nodes.append(node);
    }
    
    //第一个
    var firstNode:XNodeData{
        return nodes[0];
    }
    
    //最后一个
    var lastNode:XNodeData{
        return nodes[nodes.count - 1];
    }
    
    //长度
    var length:Int{
        return nodes.count;
    }
    
    var description:String{
        return "\(chianType) -- nodes:\(nodes)";
    }
    
    var hashValue:Int{
        return nodes.reduce(0){ $0.hashValue ^ $1.hashValue }
    }
    
    //chian type
    enum ChianType:CustomStringConvertible
    {
        case Horizontal, Vertical, Diagonal
        
        var description:String{
            switch self
            {
            case .Horizontal:
                return "horizontal";
            case .Vertical:
                return "vertical";
            case .Diagonal:
                return "diagonal";
            }
        }
    }
}


func ==(lsh:Chian, rsh:Chian) -> Bool
{
    return lsh.nodes == rsh.nodes;
}