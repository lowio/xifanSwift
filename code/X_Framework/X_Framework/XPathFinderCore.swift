//
//  XPathFinderCore.swift
//  X_Framework
//
//  Created by 叶贤辉 on 15/10/15.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: XPathFindGridType
protocol XPathFindGridType
{
    //parent
    var parent:XPathFindGridType?{get set}
    
    //is closed
    var closed:Bool{get set}
    
    //path array
    func getPath() -> [Self];
}
extension XPathFindGridType
{
    func getPath() -> [Self]
    {
        var path:[Self] = [];
        var grid = self;
        repeat{
            path.append(grid);
            guard let temp = grid.parent as? Self else{break;}
            grid = temp;
        }while true
        return path;
    }
}
//=========================================================================

//MARK: XPathFindPriorityType
protocol XPathFindPriorityType: Equatable
{
    typealias _Grid:XPathFindGridType;
    
    //g score
    var g:Int{get set}
    
    //h score
    var h:Int{get set}
    
    //f score
    var f:Int{get}
    
    //gird
    var grid:_Grid?{set get}
    
    //init
    init(g:Int, h:Int)
    
    //priority compare
    static func compare(p1:Self, p2:Self) -> Bool
}
extension XPathFindPriorityType
{
    var f:Int{return self.h + self.g;}
    
    static func compare(p1:Self, p2:Self) -> Bool
    {
        return p1.f > p2.f;
    }
}
//func ==<_Priority:XPathFindPriorityType where _Priority._Grid:Hashable>(lsh:_Priority, rsh:_Priority) -> Bool
//{
//    return lsh.f == rsh.f && lsh.grid == rsh.grid;
//}
//=========================================================================

//MARK: XPathFindConfigType
protocol XPathFindConfigType
{
    typealias _Priority:XPathFindPriorityType;
    
    //heuristic h
    func heuristic(fromGrid: Self._Priority._Grid, _ toGrid: Self._Priority._Grid) -> Int
    
    //movementCost used by g
    func movementCost(fromGrid: Self._Priority._Grid, _ toGrid: Self._Priority._Grid) -> Int
    
    //getNeighbors
    func getNeighbors(grid: Self._Priority._Grid) -> [Self._Priority._Grid]
    
    //grid is goal?
    func isTarget(grid: Self._Priority._Grid) -> Bool
    
    //start
    var start:Self._Priority._Grid?{get set}
    
    //goal
    var goal:Self._Priority._Grid?{get set}
}
//=========================================================================

//MARK: XPathFinderType
protocol XPathFinderType
{
//    //is visited
//    func isVisited<_Grid:XPathFindGridType>(grid:_Grid) -> Bool
//    
//    //set grid visited
//    mutating func setVisited<_Grid:XPathFindGridType>(grid:_Grid) -> _Grid
//    
//    //is closed
//    mutating func isClosed<_Grid:XPathFindGridType>(grid:_Grid) -> Bool
//    
//    //set grid closed
//    func setClosed<_Grid:XPathFindGridType>(grid:_Grid) -> _Grid
//    
//    //pathFinder
//    mutating func pathFinder<_Config:XPathFindConfigType>(pathConfig conf: _Config, completion:([_Config._Priority._Grid]) -> ())
//    
//    //pre path finder
//    mutating func prePathFinder();
}
extension XPathFinderType
{
    //pathFinder
    mutating func pathFinder<_Config:XPathFindConfigType where _Config._Priority._Grid:Hashable>(pathConfig conf: _Config, completion:([_Config._Priority._Grid]) -> ())
    {
        guard let start = conf.start else{return;}
        guard let goal = conf.goal else{return;}

        var visited:[_Config._Priority._Grid:_Config._Priority] = [:];  //create visited
        let h = conf.heuristic(start, goal);
        var current:_Config._Priority = self._createPathPriority(0, h);
        current.grid = start;
        
        visited[start] = current;         //set visited
        var opened = XPriorityQueue<_Config._Priority>(compare: _Config._Priority.compare);
        opened.push(current);

        defer{
            let temp = current.grid!
            completion(temp.getPath());
        }

        repeat{
            current = opened.pop()!;
            guard let grid = current.grid else{break;}
            guard !conf.isTarget(grid) else{break;}
            current.grid?.closed = true;    //set closed
            visited[grid] = current;        //update visited close state


            let neighbors = conf.getNeighbors(grid);
            for n in neighbors
            {
                let g = current.g + conf.movementCost(grid, n);
                guard let v = visited[n] else{  //get visited
                    var o:_Config._Priority = self._createPathPriority(g, conf.heuristic(n, goal))
                    o.grid = n;
                    o.grid?.parent = grid;
                    visited[n] = o;         //set visited
                    opened.push(o);
                    continue;
                }
                
                
                guard !v.grid!.closed else{continue;}
                guard v.g > g else{continue;}
                var updateNode = v;
                updateNode.grid?.parent = grid;
                updateNode.g = g;
                visited[n] = updateNode;            //update visited g && parent
                print("注意前方高能：此处出现已经在访问列表中的g需要更新", __LINE__)
                guard let index = opened.indexOf(v) else{continue;}
                opened.update(updateNode, atIndex: index);
            }
        }while !opened.isEmpty
    }
}
private extension XPathFinderType
{
    //create path node
    func _createPathPriority<_PathPriority:XPathFindPriorityType>(g:Int, _ h:Int) -> _PathPriority
    {
        return _PathPriority.init(g:g, h:h);
    }
}
//=========================================================================