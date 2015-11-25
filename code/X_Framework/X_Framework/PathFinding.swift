//
//  PathFinding.swift
//  X_Framework
//
//  Created by 173 on 15/11/25.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation


//MARK: == PathFinderType ==
public protocol PathFindingType {
    
    //source type
    typealias Source: PFSourceType;
    
    //request type
    typealias Request: PFRequestType;
    
    //position Type
    typealias Position: Hashable;
    
    //source
    var source: Self.Source! {get}
    
    //request
    var request: Self.Request! {get set}
    
    //return element
    func elementOf<E: PFElementType where E.Position == Self.Position>(position: E.Position, _ parent: E, _ visited: E?) -> E?
}
extension PathFindingType {
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
extension PathFindingType where Self.Source.Position == Self.Position, Self.Request.Position == Self.Position {
    
    //execute
    mutating func execute<Q: PFQueueType where Q.Element.Position == Self.Position>(queue: Q, @noescape findPath: ([Self.Position]) -> ()) -> Q {
        let originElement = Q.Element(g: 0, h: 0, position: self.request.origin, parent: nil);
        var q = queue;
        q.insert(originElement);
        repeat{
            guard let current = q.popBest() else {break;}
            let position = current.position;
            
            if let flag = self.request.findGoal(position) {
                let path = self.decompress(current);
                findPath(path);
                if flag {return q;}
            }
            
            let neighbors = self.source.neighborsOf(position);
            neighbors.forEach{
                let p = $0;
                let visited = queue[p];
                guard let ele = self.elementOf(p, current, visited) else {return;}
                visited == nil ? q.insert(ele) : q.update(ele);
            }
        }while true
        return q;
    }
}
