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
    
    //find path, return path from start to goal
    mutating func find<S: PFSourceType>(start: S.Position, goal: S.Position, source: S) -> [S.Position]
    
    //find paths, return paths from start to goals
    mutating func find<S: PFSourceType>(start: S.Position, goals: [S.Position], source: S) -> [[S.Position]]
}


extension PFQueueType {
    //position type
    typealias P = Self.Element.Position;
    
    //execute
    mutating func execute<S: PFSourceType where P == S.Position>(origin: P, source: S, @noescape isComplete: (P) -> Bool?) -> [[P]] {
        let originElement = Self.Element(g: 0, h: 0, position: origin, parent: nil);
        self.insert(originElement);
        var paths: [[P]] = [];
        repeat{
            guard let current = self.popBest() else {break;}
            let position = current.position;
            if let flag = isComplete(position) {
                let path = self.decompress(current);
                paths.append(path);
                guard !flag else {break;}
            }
            let neighbors = source.neighborsOf(position);
            neighbors.forEach {
                print($0)
//                self.explore($0, parent: current, source: source, queue: &self);
            }
        }while true
        return paths;
    }
    
    //decompress path
    func decompress(element: Self.Element) -> [Self.Element.Position]
    {
        var path: [Self.Element.Position] = [];
        var ele = element;
        repeat{
            path.append(ele.position);
            guard let parent = ele.parent as? Self.Element else{break;}
            ele = parent;
        }while true
        return path.reverse();
    }
}


//MARK: == PathFinderDelegateType ==
public protocol PathFinderDelegateType {
    //explore position
    func explore<S: PFSourceType, Q: PFQueueType where Q.Element.Position == S.Position>(position: Q.Element.Position, parent: Q.Element, source: S, inout queue: Q)
}
extension PathFinderDelegateType {
    //execute
    func execute<S: PFSourceType, Q: PFQueueType where Q.Element.Position == S.Position>(origin: S.Position, source: S, inout queue: Q, @noescape findPath: (Q.Element) -> Bool?) {
        let originElement = Q.Element(g: 0, h: 0, position: origin, parent: nil);
        queue.insert(originElement);
        repeat{
            guard let current = queue.popBest() else {break;}
            if let flag = findPath(current) where flag {
                break;
            }
            let position = current.position;
            let neighbors = source.neighborsOf(position);
            neighbors.forEach{
                self.explore($0, parent: current, source: source, queue: &queue);
            }
        }while true
    }
    
    //decompress path
    func decompress<Element: PFElementType>(element: Element) -> [Element.Position]
    {
        var path: [Element.Position] = [];
        var ele = element;
        repeat{
            path.append(ele.position);
            guard let parent = ele.parent as? Element else{break;}
            ele = parent;
        }while true
        return path.reverse();
    }
}