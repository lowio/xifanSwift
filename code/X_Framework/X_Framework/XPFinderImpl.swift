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

//MARK: XPFinderMap
struct XPFinderMap<G:XPFinderGridType>: XPFinderMapType {
    typealias _Grid = G;
    
    private(set) var diagonal:Bool;
    private(set) var start:G?;
    private(set) var goal:G?;
    
    //heuristic h
    func heuristic(fromGrid: G, _ toGrid: G) -> Int{
        let x = abs(fromGrid.x - toGrid.x);
        let y = abs(fromGrid.y - toGrid.y);
        return x + y;
    }
    
    //getNeighbors
    func getNeighbors(grid: G) -> [G]{
        var neighbors = [_Grid]();

//        guard let index = getPosition(grid.x, grid.y) else{
//            return [];
//        }
//        let temp = self[index]!;
//        if walkable(temp)
//        {
//            neighbors.append(temp);
//        }
        
        return neighbors;
    }
    
    //if grid walkable
    func walkable(grid: G) -> Bool{
        return true;
    }
    
    
}