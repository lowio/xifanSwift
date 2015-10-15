//
//  XPathFind2DImpl.swift
//  X_Framework
//
//  Created by 叶贤辉 on 15/10/16.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//=========================================================================
//MARK: XPFinder2D
struct XPFinder2D{}
extension XPFinder2D: XPathFinderType{}

//=========================================================================
//MARK: XPFGrid2D
struct XPFGrid2D: XPathFindGridType, Hashable {
    private(set) var x, y:Int;
    
    var closed:Bool;
    
    var parent:XPathFindGridType?
    
    init(_ x:Int, _ y:Int)
    {
        self.x = x;
        self.y = y;
        self.closed = false;
    }
    
    var hashValue:Int{return "\(x),\(y)".hashValue;}
}
func ==(lsh:XPFGrid2D, rsh:XPFGrid2D) -> Bool
{
    return lsh.x == rsh.x && lsh.y == rsh.y;
}

//=========================================================================
//MARK: XPFPriority
struct XPFPriority: XPathFindPriorityType
{
    typealias _Grid = XPFGrid2D;
    var g, h:Int;
    var grid:_Grid?
    private var _flag:Int;
    private var _f:Int;
    var f:Int{return self._f;}
    
    init(g: Int, h: Int) {
        self.g = g;
        self.h = h;
        self._f = self.g + self.h;
        self._flag = XPFPriority._FLAG++;
    }
    
    //计数器
    private static var _FLAG:Int = 0;
    
    static func compare(p1:XPFPriority, p2:XPFPriority) -> Bool
    {
        let bl = p1.f > p2.f;
        return bl ?? (p1._flag > p2._flag);
    }
}
func ==(lsh:XPFPriority, rsh:XPFPriority) -> Bool
{
    return lsh.f == rsh.f && lsh.grid == rsh.grid;
}
//=========================================================================
//MARK: XPFConfig
struct XPFConfig<T:XPFinderWalkable>
{
    typealias _Priority = XPFPriority;
    
    typealias _Grid = _Priority._Grid;
    
    var start, goal:_Grid?;
    
    private var algorithm:XPFAlgorithm2D;
    
    private(set) var config:XArray2D<T>;
    
    init(config:XArray2D<T>, algorithm:XPFAlgorithm2D)
    {
        self.config = config;
        self.algorithm = algorithm;
    }
}
extension XPFConfig: XPathFindConfigType
{
    func heuristic(fromGrid: _Grid, _ toGrid: _Grid) -> Int
    {
        return algorithm.heuristic(fromGrid.x, fromGrid.y, toGrid.x, toGrid.y);
    }
    
    func movementCost(fromGrid: _Grid, _ toGrid: _Grid) -> Int
    {
        guard let element = config[toGrid.x, toGrid.y] else{return 1;}
        return element.movementCost;
    }
    
    func getNeighbors(grid: _Grid) -> [_Grid]
    {
        var neighbors = [_Grid]();
        let pos = algorithm.neighbors(grid.x, grid.y);
        for p in pos
        {
            let x = p.0;
            let y = p.1;
            guard walkable(x, y) else{continue;}
            neighbors.append(_Grid(x, y));
        }
        return neighbors;
    }
    
    func isTarget(grid: _Grid) -> Bool
    {
        return grid == self.goal
    }
    
    func walkable(x:Int, _ y:Int) -> Bool
    {
        guard let element = config[x, y] else{return false;}
        return element.walkable;
    }
}

//=========================================================================
//MARK: XPFinderWalkable
protocol XPFinderWalkable
{
    var movementCost:Int{get}
    var walkable:Bool{get}
}
//=========================================================================
//MARK XPFAlgorithm2D
enum XPFAlgorithm2D
{
    case Manhattan, Diagonal
    
    //heuristic
    func heuristic(fx:Int, _ fy:Int, _ tx:Int, _ ty:Int) -> Int
    {
        switch self{
        case .Manhattan:
            let x = abs(fx - tx);
            let y = abs(fy - ty);
            return x + y;
        case .Diagonal:
            let x = abs(fx - tx);
            let y = abs(fy - ty);
            return x + y + min(x, y);
        }
    }
    
    //neighbors
    func neighbors(x:Int, _ y:Int) -> [(Int, Int)]
    {
        switch self{
        case .Manhattan:
            return [(x-1, y), (x, y+1), (x+1, y), (x, y-1)];
        case .Diagonal:
            return [(x-1, y-1), (x-1, y), (x-1, y+1), (x, y+1),(x+1, y+1),  (x+1, y), (x+1, y-1), (x, y-1)];
        }
    }
}