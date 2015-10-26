//
//  OptimumFinder2DImpl.swift
//  X_Framework
//
//  Created by 叶贤辉 on 15/10/25.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: finder point 2d
public protocol FinderPoint2D: Hashable
{
    //x position
    var x:Int{get}
    
    //y position
    var y:Int{get}
    
    //cost
    var cost:Int{get}
    
    init(x:Int, y:Int, cost:Int)
}

public struct Point2D: FinderPoint2D
{
    //x, y
    public private(set) var x, y, cost:Int;
    
    public init(x:Int, y:Int, cost:Int)
    {
        self.x = x;
        self.y = y;
        self.cost = cost;
    }
    
    public var hashValue:Int{
        return "\(x), \(y)".hashValue;
    }
}

public func ==(rsh:Point2D, lsh:Point2D) -> Bool
{
    return rsh.x == lsh.x && rsh.y == lsh.y;
}

//MARK: finder huristic 2d
public enum FinderHuristic2D<T: FinderPoint2D>
{
    case Manhattan, Euclidean, Octile, Chebyshev
}
extension FinderHuristic2D: FinderHeuristic
{
    public typealias _Point = T;
    
    public func getHeuristic(from: _Point, toPoint: _Point) -> Int {
        let dx = abs(from.x - toPoint.x);
        let dy = abs(from.y - toPoint.y);
        switch self{
        case .Manhattan:
            return dx + dy;
        case .Euclidean:
            return Int(sqrt(CGFloat(dx * dx + dy * dy)));
        case .Octile:
            let f:CGFloat = CGFloat(M_SQRT2) - 1;
            let _dx = CGFloat(dx);
            let _dy = CGFloat(dy);
            return Int(_dx < _dy ? f * _dx + _dy : f * _dy + _dx);
        case .Chebyshev:
            return max(dx, dy);
        }
    }
}


//MARK: finder data source 2d
public struct FinderDataSource2D<T: FinderPoint2D>
{
    //config
    private let config:Array2D<Int>;
    
    //dx dy
    private var dpoints:[(Int, Int)];
    
    init(config: Array2D<Int>, diagonal:Bool)
    {
        self.config = config;
        self.dpoints = [];
        self.useDiagonal(diagonal);
    }
    
    //set diagoanl;
    public mutating func useDiagonal(value:Bool)
    {
        self.dpoints = value ? [(-1, -1), (-1, 0), (-1, 1), (0, 1),(1, 1),  (1, 0), (1, -1), (0, -1)] : [(-1, 0), (0, 1), (1, 0), (0, -1)];
    }
}
extension FinderDataSource2D: FinderDataSource
{
    public typealias _Point = T;
    
    //get neighbors
    public func getNeighborsOf(point: _Point) -> [_Point]
    {
        var points:[_Point] = [];
        for dp in self.dpoints
        {
            let x = dp.0 + point.x;
            let y = dp.1 + point.y;
            guard config.isValid(x, y) else {continue;}
            let cost = self.config[x, y];
            guard cost > 0 else {continue;}
            let p = _Point(x: x, y: y, cost: cost);
            points.append(p);
        }
        return points;
    }
    
    //get cost
    public func getCostFrom(point: _Point, toPoint: _Point) -> Int
    {
        return point.cost;
    }
}