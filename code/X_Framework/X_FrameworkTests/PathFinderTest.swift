//
//  PathFinderTest.swift
//  X_Framework
//
//  Created by xifanGame on 15/9/17.
//  Copyright © 2015年 yeah. All rights reserved.
//

import UIKit
@testable import X_Framework;



func pathFinderTest() {
//    let start = PFinderPosition2D(x: 24, y: 24);
//    let goals = [PFinderPosition2D(x: 14, y: 14), PFinderPosition2D(x: 30, y: 30), PFinderPosition2D(x: 14, y: 30), PFinderPosition2D(x: 30, y: 14)];
//    let map = TestMap(heristic: .Euclidean, passMode: .Diagonal);
//    var finder = BreadthBestPFinder<PFinderPosition2D>(neighborsOf: map.neighbors);
//
//    var path: [[PFinderPosition2D]] = [];
//    finder.searching(start, goals: goals, findGoal: {
//        path.append($0);
//        })
//        {
//            var conf = Array2D(columns: map.size, rows: map.size, repeatValue: "1");
//            
//            for (k, _) in finder.visiteList{
//                conf[k.x, k.y] = "#";
//            }
//            
//            for ps in path{
//                for p in ps{
//                    conf[p.x, p.y] = "^";
//                }
//            }
//            conf[start.x, start.y] = "S";
//            for g in goals{
//                conf[g.x , g.y] = "G";
//            }
//            print(conf);
//            print("visited count: ", finder.visiteList.count);
//        }
    
    
    //CGflaot 比 Int 快？
    //实现协议后 实现协议中已经实现的方法效率会高很多
    
    //具体文章：Enum链表 自定义一个2dgenerator
    
    //    jump point search
    //    dic不可取 效率太低 想其他办法 index ...
    //    diagoanl算法有问题
    //    load map config json 格式的
}


public struct TestMap{
    let config: Array2D<Int>;
    
    let neighbors: (PFinderPosition2D) -> [PFinderPosition2D];
    
    let heristic: (PFinderPosition2D, PFinderPosition2D) -> CGFloat;
    
    let cost: (PFinderPosition2D, PFinderPosition2D) -> CGFloat;
    
    let size: Int;
    
    init(heristic: PFinderHuristic2D, passMode: PFinderPassMode2D = .Straight, _ s: Int = 50){
        var c = Array2D(columns: s, rows: s, repeatValue: 1);
        c[17, 17] = 0;
        c[16, 17] = 0;
        c[18, 17] = 0;
        self.size = s;
        self.config = c;
        self.heristic = heristic.heuristicOf;
        self.cost = {
            let _ = $0;
            let p2 = $1;
            return CGFloat(c[p2.x, p2.y]);
        }
        let ns = passMode.neighborsOffset();
        self.neighbors = {
            let p = $0;
            var arr: [PFinderPosition2D] = [];
            ns.forEach{
                let op = $0;
                let x = op.0 + p.x;
                let y = op.1 + p.y;
                guard c.columns > x && x > -1 && y > -1 && c.rows > y else {return;}
                let cst = c [x, y];
                guard cst > 0 else {return;}
                arr.append(PFinderPosition2D(x: x, y: y));
            }
            return arr;
        }
    }
}