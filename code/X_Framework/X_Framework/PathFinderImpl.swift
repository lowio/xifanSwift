//
//  PathFinderImpl.swift
//  X_Framework
//
//  Created by 叶贤辉 on 15/11/7.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation


//MARK: == GreedyBestSearch ==
public struct GreedyBestSearch<T: PathHElementType>
{
    //openlist
    private var openList: BinaryPriorityQueue<T>!;
    
    //visitelist
    private var visiteList: [T.Position: T]!;
    
    //reset
    private mutating func reset()
    {
        self.openList = BinaryPriorityQueue<T>{return $0.h < $1.h;};
        self.visiteList = [:];
    }
    
    public init(){}
}
//MARK: extension PFElementGreneratorType
extension GreedyBestSearch: PFElementGreneratorType
{
    //next best element
    public mutating func next() -> T? {
        return self.openList.popBest();
    }
    
    //if contains element at position return it, otherwise return nil
    public subscript(position: T.Position) -> T? {
        set{
            guard let element = newValue else {return;}
            guard !element.isClosed else{
                self.visiteList[position] = element;
                return;
            }
            
            self.openList.insert(element);
            self.visiteList[position] = element;
        }
        get{
            return self.visiteList[position];
        }
    }
}
//MARK: extension PathFinderProcessorType
extension GreedyBestSearch: PathFinderProcessorType
{
    public mutating func execute<R : PathFinderRequest where R.Position == T.Position>(request: R, success: ([T.Position]) -> ()) {
        self.reset();
        self.execute(request, openList: self, success: success);
    }
    
    public func getElementBy<R : PathFinderRequest where R.Position == T.Position>(position: T.Position, _ request: R, _ chainFrom: T?) -> T? {
        guard let _ = self.visiteList[position] else {
            return T(h: request.heuristicOf(position), position: position, parent: chainFrom);
        }
        return nil;
    }
}

//MARK: == DijkstraSearch
public struct DijkstraSearch<T: PathGElementType>
{
    //openlist
    private var openList: BinaryPriorityQueue<T>!;
    
    //visitelist
    private var visiteList: [T.Position: T]!;
    
    //reset
    private mutating func reset()
    {
        self.openList = BinaryPriorityQueue<T>{return $0.g < $1.g;};
        self.visiteList = [:];
    }
    public init(){}
}

//MARK: extension PFElementGreneratorType
extension DijkstraSearch: PFElementGreneratorType
{
    //next best element
    public mutating func next() -> T? {
        return self.openList.popBest();
    }
    
    //if contains element at position return it, otherwise return nil
    public subscript(position: T.Position) -> T? {
        set{
            guard let element = newValue else {return;}
            guard !element.isClosed else{
                self.visiteList[position] = element;
                return;
            }
            
            self.openList.insert(element);
            self.visiteList[position] = element;
        }
        get{
            return self.visiteList[position];
        }
    }
}

//MARK: extension PathFinderProcessorType
extension DijkstraSearch: PathFinderProcessorType
{
    public mutating func execute<R : PathFinderRequest where R.Position == T.Position>(request: R, success: ([T.Position]) -> ()) {
        self.reset();
        self.execute(request, openList: self, success: success);
    }
    
    public mutating func getElementBy<R : PathFinderRequest where R.Position == T.Position>(position: T.Position, _ request: R, _ chainFrom: T?) -> T? {
        guard let parent = chainFrom else{
            return T(position: position, parent: nil);
        }
        
        let g = parent.g + request.costBetween(parent.position, and: position);
        guard let visited = self.visiteList[position] else {
            return T(g: g, position: position, parent: parent);
        }
        guard !visited.isClosed && g < visited.g else {return nil;}
        
        var element = visited;
        element.setParent(parent, g: g);
        guard let i = (self.openList.indexOf{return $0.position == element.position;})else{return nil;}
        
        self.openList.replaceElement(element, atIndex: i);
        self.visiteList[element.position] = element;
        return nil;
    }
}


//MARK: == AstarSearch ==
public struct AstarSearch<T: PathFElementType>
{
    //openlist
    private var openList: BinaryPriorityQueue<T>!;
    
    //visitelist
    private var visiteList: [T.Position: T]!;
    
    //reset
    private mutating func reset()
    {
        self.openList = BinaryPriorityQueue<T>{return $0.f < $1.f;};
        self.visiteList = [:];
    }
    
    public init(){}
}
//MARK: extension PFElementGreneratorType
extension AstarSearch: PFElementGreneratorType
{
    //next best element
    public mutating func next() -> T? {
        return self.openList.popBest();
    }
    
    //if contains element at position return it, otherwise return nil
    public subscript(position: T.Position) -> T? {
        set{
            guard let element = newValue else {return;}
            guard !element.isClosed else{
                self.visiteList[position] = element;
                return;
            }
            
            self.openList.insert(element);
            self.visiteList[position] = element;
        }
        get{
            return self.visiteList[position];
        }
    }
}
//MARK: extension PathFinderProcessorType
extension AstarSearch: PathFinderProcessorType
{
    public mutating func execute<R : PathFinderRequest where R.Position == T.Position>(request: R, success: ([T.Position]) -> ()) {
        self.reset();
        self.execute(request, openList: self, success: success);
    }
    
    public mutating func getElementBy<R : PathFinderRequest where R.Position == T.Position>(position: T.Position, _ request: R, _ chainFrom: T?) -> T? {
        let h = request.heuristicOf(position);
        guard let parent = chainFrom else{
            return T(h: h, position: position, parent: nil);
        }
        
        let g = parent.g + request.costBetween(parent.position, and: position);
        guard let visited = self.visiteList[position] else {
            return T(g: g, h: h, position: position, parent: chainFrom)
        }
        guard !visited.isClosed && g < visited.g else {return nil;}
        
        var element = visited;
        element.setParent(parent, g: g);
        guard let i = (self.openList.indexOf{return $0.position == element.position;})else{return nil;}
        self.openList.replaceElement(element, atIndex: i);
        self.visiteList[element.position] = element;
        return nil;
    }
}






/**
    next:
    breadthfirst
    T ->

*/



