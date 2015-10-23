//
//  PathFinderTest.swift
//  X_Framework
//
//  Created by 173 on 15/9/17.
//  Copyright © 2015年 yeah. All rights reserved.
//

import UIKit
@testable import X_Framework;

extension XPFinderTile2D: CustomStringConvertible
{
    var description:String{
        return "\(movementCost)";
    }
}

func pathFinderTest() {
    
//    let size = 50;
//    var config = Array2D<XPFScannable._Tile>(columns: size, rows: size);
//    for c in 0..<size
//    {
//        for r in 0..<size
//        {
//            var v = XPFScannable._Tile.init(c, r);
//            v.movementCost = 1;
//            config[c, r] = v;
//        }
//    }
//    var xpf = XPFinder2D<XPFScannable>(config: config, algorithm: XPFAlgorithm2D.Manhattan);
//    xpf.start = XPFScannable._Tile(3, 3);
//    xpf.goal = XPFScannable._Tile(20, 23);
//    
//    var c = xpf.config;
//    
//    var path:[XPFScannable._Tile] = [];
//    xpf.findPath({
//        path = $0;
//    })
//    {
//        for v in $0{
//            var temp = v;
//            temp.movementCost = 0;
//            c[v.x, v.y] = temp;
//        }
//        for v in path
//        {
//            var temp = v;
//            temp.movementCost = 3;
//            c[v.x, v.y] = temp;
//        }
//        print(c);
//        print($0.count, "", path.count)
//    }
    
    
    
    
    //    Queue create/ completion/ getneighbors/ Queue Element create heuristic movementcost/ check g and update (可以提出update方法， 根据不同的queue.element的权重g来更新）

    //    tile 中的 passable也不应该出现
    //    jump point search
    //    dic不可取 效率太低 想其他办法 index ...
    //    diagoanl算法有问题
    //    load map config json 格式的
    //    改变compare方法后打印visited看看变化
    //    优化visited和closed存储方式
    //    其它：优化算法 添加alpha值用于配置算法趋向Dijkstra还是Best-First-Search根据结果打印
}