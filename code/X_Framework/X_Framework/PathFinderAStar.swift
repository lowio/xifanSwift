//
//  PathFinderBreadthFirst.swift
//  X_Framework
//
//  Created by 叶贤辉 on 15/10/19.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

protocol PathFinderAStarType: PathFinderType
{
    //get neighbors
    func getNeighborsAt(node: _Node) -> [_Node];
    
    //get visited node
    func getVisited(node: _Node) -> _Node?;
    
    //get closed node
    func getClosed(node: _Node) -> _Node?;
    
    //update visited node
    func updateVisited(node: _Node, _ parent: _Node)
}
extension PathFinderAStarType
{
    mutating func scanningAroundAt(node: _Node)
    {
        let neighbors = self.getNeighborsAt(node);
        for n in neighbors
        {
            guard let v = self.getVisited(n) else {
                self.setVisited(n, node);   //set n visited
                continue;
            }
            
            if let _ = self.getClosed(n) {continue;}
            self.updateVisited(v, node);    //update visited node
        }
    }
}