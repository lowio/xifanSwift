//
//  PathFinding.swift
//  X_Framework
//
//  Created by 173 on 15/11/25.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: == PathFindingType ==
public protocol PathFindingType {
    //request type
    typealias Request: PFRequestType;
    
    //exploring
    @warn_unused_result
    func exploring<S: PFSourceType, E: PFElementType where S.Position == Self.Request.Position, E.Position == Self.Request.Position>(position: S.Position, parent: E, visited: E?, request: Self.Request, source: S) -> E?
}
extension PathFindingType {
    
    //Position
    typealias P = Self.Request.Position;
    
    //execute
    func execute<S: PFSourceType, Q: PFQueueType where S.Position == P, Q.Element.Position == P>(inout queue: Q, request: Self.Request, source: S) -> [[P]] {
        let originElement = Q.Element(g: 0, h: 0, position: request.origin, parent: nil);
        queue.insert(originElement);
        var req = request;
        var paths: [[P]] = [];
        repeat{
            guard let current = queue.popBest() else {break;}
            let position = current.position;
            if let flag = req.findGoal(position) {
                let path = self.decompress(current);
                paths.append(path);
                guard !flag else {return paths;}
            }
            let neighbors = source.neighborsOf(position);
            neighbors.forEach{
                let p = $0;
                let visited = queue[p];
                guard let ele = self.exploring(p, parent: current, visited: visited, request: req, source: source) else {return;}
                visited == nil ? queue.insert(ele) : queue.update(ele);
            }
        }while true
        return paths;
    }
    
    //decompress path
    func decompress<E: PFElementType>(element: E) -> [E.Position]
    {
        var path: [E.Position] = [];
        var ele = element;
        repeat{
            path.append(ele.position);
            guard let parent = ele.parent as? E else{break;}
            ele = parent;
        }while true
        return path.reverse();
    }
}
