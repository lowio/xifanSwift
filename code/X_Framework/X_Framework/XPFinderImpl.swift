//
//  XPFinderImpl.swift
//  X_Framework
//
//  Created by 173 on 15/10/14.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//=========================================================================
//MARK: XPFinder
struct XPFinder{}
extension XPFinder: XPFinderType{}

//=========================================================================
//MARK: XPFinderGrid
struct XPFinderGrid: XPFinderGridType {
    private(set) var x, y:Int;
    
    var closed:Bool;
    
    var p:XPFinderGridType?;
    
    init(_ x:Int, _ y:Int)
    {
        self.x = x;
        self.y = y;
        self.closed = false;
    }
}

//=========================================================================
//MARK: XPFinderNode
struct XPFinderNode<G:XPFinderGridType>: XPFinderNodeType
{
    typealias _Grid = G;
    var g, h:Int;
    private(set) var priority:Int;
    var grid:G?
    
    init(g: Int, h: Int) {
        self.g = g;
        self.h = h;
        self.priority = g + h;
    }
}

//=========================================================================
//MARK: XPFinderMap
struct XPFinderMap<G:XPFinderGridType, T:XPFinderWalkable>
{
    typealias _Grid = G;
    
    var start, goal:_Grid?;
    
    private var algorithm:XPFinderAlgorithm;
    
    private(set) var config:XArray2D<T>;

    init(config:XArray2D<T>, algorithm:XPFinderAlgorithm)
    {
        self.config = config;
        self.algorithm = algorithm;
    }
}
extension XPFinderMap: XPFinderMapType
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
//MARK XPFinderAlgorithm
enum XPFinderAlgorithm
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