//
//  FinderTest.swift
//  X_Framework
//
//  Created by xifanGame on 15/9/17.
//  Copyright © 2015年 yeah. All rights reserved.
//

import UIKit
@testable import X_Framework;


typealias PF2 = BreadthBestPathFinder<FinderPoint2D>
//typealias PF2 = DijkstraPathFinder<FinderPoint2D>
typealias PF = AstarFinder<FinderPoint2D>
//typealias PF = GreedyBestFinder<FinderPoint2D>

let h2d = FinderHeuristic2D.Manhattan;
func pathFinderTest(markVisited: Bool = true, markPath: Bool = true, isDiagnal: Bool = true, multiGoals: Bool = false) {
    let size = 50;
    let mp = size - 1;
    let conf = Array2D(columns: size, rows: size, repeatValue: 1);

    
    let m: FinderModel = isDiagnal ? .Diagonal : .Straight;
    

    var start = FinderPoint2D(x: 17, y: 17);
    let goals = [FinderPoint2D(x: 0, y: 0), FinderPoint2D(x: mp, y: 0), FinderPoint2D(x: 0, y: mp), FinderPoint2D(x: mp, y: mp)];
    let goal = goals[0];
    
    let source = TestFinderDataSource(conf: conf, m);
    var path: [FinderPoint2D: [FinderPoint2D]] = [:];
    var visited: [FinderPoint2D: FinderPoint2D]
    if multiGoals {
        let finder = PF2();
        path = finder.find(from: goals, to: start, option: source);
//        visited = finder.backtraceRecord();
    }
    else{
        start = goals[3];
        let finder = PF();
        path = finder.find(from: start, to: goal, option: source);
//        visited = finder.backtraceRecord();
    }
    
    
    guard markPath else {return;}
    
    var printMap = Array2D(columns: size, rows: size, repeatValue: "✅");
//    if markVisited{
//        visited.forEach{
//            let point = $0;
//            let parentpoint = $1;
//            let arrow = TestArrow.getArrow(point.x, y1: point.y, x2: parentpoint.x, y2: parentpoint.y).description;
//            printMap[point.x , point.y] = arrow;
//        }
//    }
    
    path.forEach{
        let _ = $0
        let ps = $1;
        ps.forEach{
            let p = $0;
            let arrow = "📍";
            printMap[p.x, p.y] = arrow;
        }
    }
    printMap[start.x, start.y] = "🚹";
    
    for g in goals{
        printMap[g.x , g.y] = "🚺";
        guard multiGoals else{break;}
    }
    
    print(printMap);
}

struct TestFinderDataSource{
    let config: Array2D<Int>;
    
    let model: FinderModel;
    
    let heuristic = h2d;
    
    typealias Point = FinderPoint2D;
    
    init(conf: Array2D<Int>, _ model: FinderModel = .Straight){
        self.config = conf;
        self.model = model;
    }
}
extension TestFinderDataSource: FinderOption2DType{
    ///return calculate movement cost from f to t if it is validity(and exist)
    ///otherwise return nil
    func getCost(x: Int, y: Int) -> CGFloat? {
        guard x < self.config.columns && y < self.config.rows else {return .None;}
        return CGFloat(self.config[x, y]);
    }
}