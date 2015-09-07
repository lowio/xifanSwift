//
//  XPathFinder.swift
//  xlib
//
//  Created by 173 on 15/9/1.
//  Copyright (c) 2015年 yeah. All rights reserved.
//

import UIKit

//MARK: XPF_Grid
struct XPF_Grid: XPFGridProtocol, Hashable {
    
    var x:Int = 0;
    var y:Int = 0;
    var g:CGFloat = 0.0;
    var h:CGFloat = 0.0;
    var f:CGFloat{return g + h;}
    var isClosed:Bool = false;
    var isOpened:Bool = false;
    var p:XPFGridProtocol?;
    
    var hashValue:Int{ return x^y; }
}

func ==(lsh:XPF_Grid, rsh:XPF_Grid) -> Bool
{
    return lsh.x == rsh.x && lsh.y == rsh.y;
}

//MARK: XPathFinder
struct XPathFinder {
    
}


//MARK: XPathFinder extension XPFProtocol
extension XPathFinder: XPFProtocol
{
    func pathFinder<M: XPFMapProtocol where M.G: Hashable>
        (startGrid sg: M.G, goalGride gg: M.G, map: M, completion: ([M.G]) -> ())
    {
        var visited:[Int:M.G] = [:];
        visited[sg.hashValue] = sg;
        var openQueue = XPriorityQueue<M.G>{return $0.0.f > $0.1.f};
        openQueue.push(sg);
        
        while let grid = openQueue.pop()
        {
            visited[grid.hashValue]?.isClosed = true;
            visited[grid.hashValue]?.isOpened = false;
            if grid == gg
            {
                let path = rebuildPath(grid);
                completion(path);
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
                            visited[ne.hashValue] = ne;
                            if let i = self.getElementIndex(openQueue, element: ne)
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
                e.h = map.getHeuristicCost(fromGrid: grid, toGrid: e);
                e.p = grid;
                openQueue.push(e);
            }
            
        }
    }
}

//MARK: XPathFinder extension private method
private extension XPathFinder
{
    
    private func getElementIndex<T:Hashable>(queue:XPriorityQueue<T>, element:T) -> Int?
    {
        let c = queue.count;
        for i in 0..<c
        {
            if queue.getElement(i) == element
            {
                return i;
            }
        }
        return nil;
    }
    
    //rebuild path
    private func rebuildPath<G:XPFGridProtocol>(grid:G) -> [G]
    {
        var path = [G]();
        return path;
    }
}