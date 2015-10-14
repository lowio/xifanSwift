//
//  XPFinderImpl.swift
//  X_Framework
//
//  Created by 173 on 15/10/14.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation


//MARK: XPFinderGrid
struct XPFinderGrid: XPFinderGridType {
    var x, y:Int;
    
    var closed:Bool;
    
    var p:XPFinderGridType?;
    
    init(x:Int, y:Int)
    {
        self.x = x;
        self.y = y;
        self.closed = false;
    }
}

//MARK: XPFinderNode
struct XPFinderNode<G:XPFinderGridType>: XPFinderNodeType
{
    typealias _Grid = G;
    var g:Int;
    var h:Int;
    private(set) var priority:Int;
    var grid:G?
    
    init(g: Int, h: Int) {
        self.g = g;
        self.h = h;
        self.priority = g + h;
    }
}

//MARK: XPFinder
struct XPFinder{}
extension XPFinder: XPFinderType{}


protocol XPFinderWalkable
{
    //movement cost
    var movementCost:Int{get}
    //walkable
    var walkable:Bool{get}
}

//MARK: XPFinderMap
struct XPFinderMap<G:XPFinderGridType, A:XArray2DType>: XPFinderMapType {
    typealias _Grid = G;
    
    var start:G?;
    var goal:G?;
    private(set) var algorithm:XPFAlgorithmType;
    private(set) var config:A;
    
    func movementCost(fromGrid: G, _ toGrid: G) -> Int
    {
        return 1;
    }
    
    func walkable(x:Int, _ y:Int) -> G?
    {
        return G(x: x, y: y);
    }

    init(config:A, algorithm:XPFAlgorithmType)
    {
        self.config = config;
        self.algorithm = algorithm;
    }
}

extension XPFinderMap where A._Element:XPFinderWalkable
{
    func walkable(x:Int, _ y:Int) -> G?
    {
        guard let g = config[y, x] where g.walkable else{return nil}
        return G(x: x, y: y);
    }
}

//MARK XPFinderAlgorithm
enum XPFinderAlgorithm: XPFAlgorithmType
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