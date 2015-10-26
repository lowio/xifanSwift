//
//  Swipe.swift
//  XCrunch
//
//  Created by 叶贤辉 on 15/4/15.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import Foundation

struct Swap: CustomStringConvertible, Hashable {
    
    //当前选中的node
    let current:XNodeData;
    
    //目标 node
    let target:XNodeData;
    
    init(current:XNodeData, target:XNodeData)
    {
        self.current = current;
        self.target = target;
    }
    
    var description:String{
        return "swipe \(current) with \(target)";
    }
    
    var hashValue:Int{
        return current.hashValue ^ target.hashValue;
    }
}

func ==(lsh:Swap, rsh:Swap) -> Bool
{
    return (lsh.current == rsh.current && lsh.target == lsh.target) || (lsh.current == rsh.target && lsh.target == rsh.current);
}
