//
//  XPathfinderType.swift
//  X_Framework
//
//  Created by 173 on 15/10/13.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//=========================================================================
//MARK: XPFinderGridType
protocol XPFinderGridType
{
    //position x
    var x:Int{get}
    
    //position y
    var y:Int{get}
    
    //is closed
    var closed:Bool{get set}
    
    //parent grid
    var p:XPFinderGridType?{get set}
    
    //init
    init(_ x:Int, _ y:Int);
}

//=========================================================================
//MARK: XPFinderMapType
protocol XPFinderMapType
{
    typealias _Grid:XPFinderGridType;
    
    //heuristic h
    func heuristic(fromGrid: _Grid, _ toGrid: _Grid) -> Int
    
    //movementCost used by g
    func movementCost(fromGrid: _Grid, _ toGrid: _Grid) -> Int
    
    //getNeighbors
    func getNeighbors(grid: _Grid) -> [_Grid]
    
    //start
    var start:_Grid?{get set}
    
    //goal
    var goal:_Grid?{get set}
}
extension XPFinderMapType
{
    func movementCost(fromGrid: _Grid, _ toGrid: _Grid) -> Int{return 1;}
}

//=========================================================================
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

//=========================================================================
//MARK: XPathFinderType
protocol XPFinderType{}
extension XPFinderType
{
    //pathFinder
    func pathFinder<_Map:XPFinderMapType, _Node:XPFinderNodeType where _Node:Equatable, _Map._Grid:Hashable, _Node._Grid == _Map._Grid>(map:_Map, _ NT:_Node.Type, completion:([XPFinderGridType]) -> ())
    {
        guard let start = map.start else{return;}
        guard let goal = map.goal else{return;}
        
        var visited:[_Node._Grid:_Node] = [:];
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
    func _buildPath(grid:XPFinderGridType) -> [XPFinderGridType]
    {
        var g:XPFinderGridType = grid;
        var path:[XPFinderGridType] = [];
        repeat{
            path.append(g);
            guard let p = g.p else{break;}
            g = p
        }while true
        return path;
    }
    
    //create path node
    func _createPathNode<_PathNode:XPFinderNodeType>(g:Int, _ h:Int) -> _PathNode
    {
        return _PathNode.init(g:g, h:h);
    }
}
//=========================================================================