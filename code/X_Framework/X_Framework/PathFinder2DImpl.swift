//
//  PathFinder2DImpl.swift
//  X_Framework
//
//  Created by 173 on 15/10/20.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//===============================================================================
//path finder 2d element
protocol PFElement2D
{
    var x:Int{get set}
    var y:Int{get set}
}

//===============================================================================
//path finder neighbors option 2d
struct PFNeighborsOption2D<T:PFElement2D> : PathFinderNeighborsOption{
    //element Type
    typealias _Element = T;
    
    //start, goal
    var start, goal: _Element?;
    
    //neighbors config
    private let neighborsConfig:[(Int, Int)];
    
    //config
    var config:XArray2D<T>;
    
    init(diagonal:Bool, config: XArray2D<T>)
    {
        var ns = [(-1, 0), (0, 1), (1, 0), (0, -1)]
        if diagonal
        {
            ns += [(-1, -1), (-1, 1), (1, 1), (1, -1)]
        }
        self.neighborsConfig = ns;
        self.config = config;
    }
    
    //get neighbors
    func getNeighbors(around node: _Element) -> [_Element]
    {
        var ns:[_Element] = [];
        self.neighborsConfig.forEach{
            let _x = node.x + $0.0;
            let _y = node.y + $0.1;
            
            var n = node;
            n.x = _x;
            n.y = _y;
            ns.append(n);
        }
        return ns;
    }
}