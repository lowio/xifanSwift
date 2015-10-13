//
//  XPathFinder.swift
//  xlib
//
//  Created by 173 on 15/9/1.
//  Copyright (c) 2015年 yeah. All rights reserved.
//

import UIKit

//MARK: XPF_Grid
struct XPF_Grid: XPFGridProtocol, Hashable, CustomStringConvertible {
    
    init(_ x:Int, _ y:Int)
    {
        self.x = x;
        self.y = y;
    }
    
    var x:Int = 0;
    var y:Int = 0;
    var g:CGFloat = 0.0;
    var h:CGFloat = 0.0;
    var f:CGFloat{return g + h;}
    var isClosed:Bool = false;
    var isOpened:Bool = false;
    var p:XPFGridProtocol?;
    var totalCount:Int = 0;
    
    var hashValue:Int{ return "\(x),\(y)".hashValue; }
    
    var description:String{
        return "x:\(x) y:\(y) f:\(f) g:\(g) h:\(h) count:\(totalCount)";
    }
}

func ==(lsh:XPF_Grid, rsh:XPF_Grid) -> Bool
{
    let flag = lsh.x == rsh.x && lsh.y == rsh.y;
    return flag;
}

//MARK: XPathFinder
struct XPathFinder {
}


//MARK: XPathFinder extension XPFProtocol
extension XPathFinder: XPFProtocol
{
    func pathFinder<M: XPFMapProtocol where M.G: Hashable>
        (startGrid sg: M.G, goalGride gg: M.G, map: M, completion: ([M.G], [Int:M.G]) -> ())
    {
        var visited:[Int:M.G] = [:];
        visited[sg.hashValue] = sg;
        var openQueue = XPriorityQueue<M.G>{
            if $0.f == $1.f{return $0.totalCount < $1.totalCount}
            return $0.f > $1.f
        };
        openQueue.push(sg);
        
        var totalCount:Int = 0;
        while !openQueue.isEmpty
        {
            totalCount++;
            var grid = openQueue.pop()!;
            visited[grid.hashValue]?.isClosed = true;
            visited[grid.hashValue]?.isOpened = false;
            if grid == gg
            {
                let path = rebuildPath(grid);
                completion(path, visited);
                break;
            }
            
            let neighbors = map.getNeighbors(grid);
            for n in neighbors
            {
                let g = grid.g + map.getMovementCost(fromGrid: grid, toGrid: n);
                if let e = visited[n.hashValue]
                {
                    if e.isClosed { continue; }
                    if e.isOpened
                    {
                        if e.g > g
                        {
                            var ne = e;
                            ne.g = g;
                            ne.p = grid;
                            ne.totalCount = totalCount;
                            visited[ne.hashValue] = ne;
                            
                            if let i = openQueue.indexOf(ne)
                            {
                                openQueue.update(ne, atIndex: i);
                            }
                        }
                        continue;
                    }
                }
                var e = n;
                e.g = g;
                e.isOpened = true;
                e.h = map.getHeuristicCost(fromGrid: grid, toGrid: gg);
                e.p = grid;
                e.totalCount = totalCount++;
                visited[e.hashValue] = e;
                openQueue.push(e);
            }
            
        }
    }
}

//MARK: XPathFinder extension private method
private extension XPathFinder
{
    
    //rebuild path
    private func rebuildPath<G:XPFGridProtocol>(grid:G) -> [G]
    {
        var path = [G]();
        var temp = grid;
        path.append(temp);
        while temp.p != nil
        {
            temp = temp.p as! G;
            path.append(temp);
        }
        return path;
    }
}