//
//  XPathFinderCore.swift
//  X_Framework
//
//  Created by 叶贤辉 on 15/10/15.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//=================== can be scanned tile protocol for XPathFinderType ===================
//MARK: XPathFinderTile
protocol XPathFinderTile
{
    //movement cost
    var movementCost:Int{get}
    
    //passable
    var passable:Bool{get}
    
    //parent
    var parent:XPathFinderTile?{get set}
    
    //convert to path chain array
    func toPathChain() -> [Self]
}
extension XPathFinderTile
{
    var movementCost:Int{return 1;}
    var passable:Bool{return self.movementCost > 0;}
    
    func toPathChain() -> [Self]
    {
        var chain:[Self] = [];
        var grid = self;
        repeat{
            chain.append(grid);
            guard let p = grid.parent as? Self else{break;}
            grid = p;
        }while true
        return chain;
    }
}

//================ path finder open list element type ================
//MARK: XPathFinderScannable
protocol XPathFinderScannable
{
    typealias _Tile:XPathFinderTile;
    
    //g score
    var g:Int{get set}
    
    //h score
    var h:Int{get set}
    
    //f score
    var f:Int{get}
    
    //tile
    var tile:Self._Tile?{get set}
    
    //is closed
    var closed:Bool{get set}
    
    //init
    init(g:Int, h:Int)
    
    //priority compare
    static func compare(p1:Self, p2:Self) -> Bool
}
extension XPathFinderScannable
{
    var f:Int{return self.h + self.g;}
    
    static func compare(p1:Self, p2:Self) -> Bool
    {
        return p1.f > p2.f;
    }
}

//========================= XPathFinderType ===========================
//MARK: XPathFinderType
protocol XPathFinderType
{
    typealias _Scannable: XPathFinderScannable;
    
    //grid is goal?
    func isTarget(element: Self._Scannable._Tile) -> Bool
    
    //start
    var start:Self._Scannable._Tile?{get}
    
    //goal
    var goal:Self._Scannable._Tile?{get}
    
    //heuristic h
    func heuristic(fromTile: Self._Scannable._Tile, _ toTile: Self._Scannable._Tile) -> Int
    
    //getNeighbors
    func getNeighbors(tile: Self._Scannable._Tile) -> [Self._Scannable._Tile]
    
    //findPath
    mutating func findPath(pathCallback:([Self._Scannable._Tile]) -> (), _ visitedCallback:([Self._Scannable._Tile] -> ())?)
}
private extension XPathFinderType
{
    //create scannable
    func _createScannable(g:Int, _ h:Int) -> Self._Scannable
    {
        return Self._Scannable.init(g:g, h:h);
    }
}
extension XPathFinderType
{
    mutating func findPath(pathCallback:([Self._Scannable._Tile]) -> (), _ visitedCallback:([Self._Scannable._Tile] -> ())? = nil)
    {
        assert(true, "findPath unimplement0")
    }
}
extension XPathFinderType where Self._Scannable._Tile:Hashable, _Scannable:Equatable
{
    mutating func findPath(pathCallback:([Self._Scannable._Tile]) -> (), _ visitedCallback:([Self._Scannable._Tile] -> ())? = nil)
    {
        guard let sg = self.start else{return;}
        guard let gg = self.goal else{return;}

        var visited:[Self._Scannable._Tile: Self._Scannable] = [:];  //create visited
        let h = self.heuristic(sg, gg);
        var _scanning:Self._Scannable = self._createScannable(0, h);
        _scanning.tile = sg;
        
        visited[sg] = _scanning;                                  //set visited
        var opened = XPriorityQueue<_Scannable>(compare: Self._Scannable.compare);
        opened.push(_scanning);

        defer{
            if let temp = _scanning.tile{
                pathCallback(temp.toPathChain());
            }
            
            if let _visitedCallback = visitedCallback{
                _visitedCallback(Array(visited.keys));
            }
        }

        repeat{
            _scanning = opened.pop()!;
            guard let tile = _scanning.tile else{break;}
            guard !self.isTarget(tile) else{break;}
            _scanning.closed = true;        //set closed
            visited[tile] = _scanning;      //update visited close state

            let neighbors = self.getNeighbors(tile);
            for n in neighbors
            {
                let g = _scanning.g + n.movementCost;
                guard let v = visited[n] else{  //get visited
                    var o:Self._Scannable = self._createScannable(g, self.heuristic(n, gg))
                    o.tile = n;
                    o.tile?.parent = tile;    //set parent tile
                    visited[n] = o;             //set visited
                    opened.push(o);
                    continue;
                }


                guard !v.closed else{continue;}
                guard v.g > g else{continue;}
                var updateNode = v;
                updateNode.tile?.parent = tile;   //set parent
                updateNode.g = g;                   //set g
                visited[n] = updateNode;            //update visited g && parent
                print("注意前方高能：此处出现已经在访问列表中的g需要更新", __LINE__)
                guard let index = opened.indexOf(v) else{continue;}
                opened.update(updateNode, atIndex: index);
            }
        }while !opened.isEmpty
    }
}
//=========================================================================