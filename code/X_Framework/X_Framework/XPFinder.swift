//
//  XPathfinderType.swift
//  X_Framework
//
//  Created by 173 on 15/10/13.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: XPFinderGridType
protocol XPFinderGridType
{
    //x
    var x:Int{get set}
    
    //y
    var y:Int{get set}
    
    //parent
    var p:XPFinderGridType?{get set}
    
    //closed
    var closed:Bool{get set}
    
    init(x:Int, y:Int);
}

protocol XPFAlgorithmType
{
    //heuristic function
    func heuristic(fx:Int, _ fy:Int, _ tx:Int, _ ty:Int) -> Int
    
    //get neighbors
    func neighbors(x:Int, _ y:Int) -> [(Int, Int)];
}

//MARK: XPFinderMapType
protocol XPFinderMapType
{
    typealias _Grid:XPFinderGridType;
    
    //heuristic h
    func heuristic(fromGrid: Self._Grid, _ toGrid: Self._Grid) -> Int
    
    //movementCost used by g
    func movementCost(fromGrid: Self._Grid, _ toGrid: Self._Grid) -> Int
    
    //getNeighbors
    func getNeighbors(grid: Self._Grid) -> [Self._Grid]
    
    //walkable
    func walkable(x:Int, _ y:Int) -> Self._Grid?
    
    //start
    var start:Self._Grid?{get set}
    
    //goal
    var goal:Self._Grid?{get set}
    
    //algorithm
    var algorithm:XPFAlgorithmType{get}
}

extension XPFinderMapType
{
    func heuristic(fromGrid: Self._Grid, _ toGrid: Self._Grid) -> Int{
        return algorithm.heuristic(fromGrid.x, fromGrid.y, toGrid.x, toGrid.y);
    }
    
    func getNeighbors(grid: Self._Grid) -> [Self._Grid]{
        var neighbors = [_Grid]();
        let pos = algorithm.neighbors(grid.x, grid.y);
        for p in pos
        {
            guard let g = walkable(p.0, p.1) else{continue;}
            neighbors.append(g);
        }
        return neighbors;
    }
    
    func movementCost(fromGrid: Self._Grid, _ toGrid: Self._Grid) -> Int
    {
        return 1;
    }
}

//MARK: XPFinderNodeType
protocol XPFinderNodeType
{
    typealias _Grid:XPFinderGridType;
    
    //g score
    var g:Int{get set}
    
    //h score
    var h:Int{get set}
    
    //f score
    var f:Int{get}
    
    //priority
    var priority:Int{get}
    
    //gird
    var grid:_Grid?{set get}
    
    //init
    init(g:Int, h:Int)
}

extension XPFinderNodeType
{
    var f:Int{return self.g + self.h;}
}

//MARK: XPathFinderType
protocol XPFinderType{}
extension XPFinderType
{
    func pathFinder<_Map:XPFinderMapType, _Node:XPFinderNodeType where _Node:Equatable, _Map._Grid:Hashable, _Map._Grid == _Node._Grid>(map:_Map, completion:([_Map._Grid]) -> ())
    {
        guard let start = map.start else{return;}
        guard let goal = map.goal else{return;}
        
        var visited:[_Map._Grid:_Node] = [:];
        var current:_Node = self._createPathNode(0, map.heuristic(start, goal));
        current.grid = start;
        
        visited[start] = current;
        var opened = XPriorityQueue<_Node>{return $0.priority > $1.priority};
        opened.push(current);
        
        defer{
            let p = self._buildPath(current.grid!);
            completion(p);
        }
        
        repeat{
            current = opened.pop()!;
            guard let grid = current.grid else{break;}
            guard grid != goal else{break;}
            current.grid?.closed = true;
            visited[grid] = current;
            
            
            let neighbors = map.getNeighbors(grid);
            for n in neighbors
            {
                let g = current.g + map.movementCost(grid, n);
                guard let v = visited[n] else{
                    var o:_Node = self._createPathNode(g, map.heuristic(n, goal))
                    o.grid = n;
                    o.grid?.p = grid;
                    visited[n] = o;
                    opened.push(o);
                    continue;
                }

                guard v.g > g else{continue;}
                var updateNode = v;
                updateNode.grid?.closed = false;
                updateNode.g = g;
                visited[n] = updateNode;
                guard let index = opened.indexOf(v) else{continue;}
                opened.update(updateNode, atIndex: index);
            }
        }while !opened.isEmpty
    }
}

private extension XPFinderType
{
    func _buildPath<_PathGrid:XPFinderGridType>(node:_PathGrid) -> [_PathGrid]
    {
        return [];
    }
    
    //create path node
    func _createPathNode<_PathNode:XPFinderNodeType>(g:Int, _ h:Int) -> _PathNode
    {
        return _PathNode.init(g:g, h:h);
    }
}