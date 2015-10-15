//
//  PathFinderTest.swift
//  X_Framework
//
//  Created by 173 on 15/9/17.
//  Copyright © 2015年 yeah. All rights reserved.
//

import UIKit

extension Int:XPFinderWalkable
{
    var movementCost:Int{return 1;}
    var walkable:Bool{return true;}
}


func pathFinderTest() {
    var xpf = XPFinder2D();
    
    let size = 50;
    var config = XArray2D<Int>(horizontal: size, rows: size);
    for i in 0..<size*size
    {
        let v = 0;
//      let v = Int(rand()%10) > 3 ?0:1;
        config[i] = v;
    }
    var map = XPFConfig(config: config, algorithm: XPFAlgorithm2D.Manhattan);
    map.start = XPFGrid2D(3, 3);
    map.goal = XPFGrid2D(20, 23);
    
    var c = map.config;
    xpf.pathFinder(pathConfig: map){
        for v in $0{
            c[v.x, v.y] = 3;
        }
        print(c);
        print($0.count)
    }
    
    //pathFinder方法的where处理一下，XPathFind2DImpl优化一下， 改变compare方法后打印visited看看变化
    //此处把visited列表中的节点全部打印
    
//    pf.pathFinder(startGrid: s, goalGride: g, map: map){
//        var grids = map.grids;
//        //        println(grids)
//        for v in $1
//        {
//            grids[v.1.y, v.1.x] = 1;
//            
//        }
//        for grid in $0
//        {
//            grids[grid.y, grid.x] = 3;
//        }
//        
//        grids[s.y, s.x] = 4;
//        grids[g.y, g.x] = 5;
//        print(grids);
//    }
}