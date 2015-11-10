//
//  PathFinderImpl.swift
//  X_Framework
//
//  Created by xifanGame on 15/11/7.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: == PriorityPFinder ==
public protocol PriorityPFinderType
{
    typealias Element: PFinderElementType;
    
    //open list
    var openList: BinaryPriorityQueue<Self.Element>! {get set}
    
    //visite list
    var visiteList: [Self.Element.Position: Self.Element]! {get set}
}
extension PriorityPFinderType
{
    public mutating func popBest() -> Self.Element? {
        return self.openList.popBest();
    }
    
    public subscript(position: Self.Element.Position) -> Self.Element? {
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

//MARK: == GreedyBestPFinder ==
public struct GreedyBestPFinder<T: PFinderDataSource>
{
    public typealias Element = PFinderElement<T.Position>;
    
    //open list
    public var openList: BinaryPriorityQueue<Element>!;
    
    //visite list
    public var visiteList: [T.Position: Element]!;
    
    //goal point
    private var goal: T.Position!;
    
    //request
    public private(set) var dataSource: T;
    
    //init
    public init(dataSource: T)
    {
        self.dataSource = dataSource;
    }
}
extension GreedyBestPFinder: PriorityPFinderType{}
extension GreedyBestPFinder: PFinderProcessor
{
    public mutating func preparation(start: T.Position, goal: T.Position) {
        self.goal = goal;
        self.openList = BinaryPriorityQueue<Element>{return $0.h < $1.h;}
        self.visiteList = [:];
    }
    
    //search position
    public mutating func searchOf(position: T.Position, _ parent: Element?) -> Element?{
        print("WARN: =======================check walkable");
        guard let _ = self[position] else {
            let h = self.dataSource.heuristicOf(position, self.goal);
            guard let p = parent else{
                return Element(g: 0, h: h, position: position, parent: nil);
            }
            return Element(g: 0, h: h, position: position, parent: p);
        }
        return nil;
    }
}

//MARK: == AstarPFinder ==
public struct AstarPFinder<T: PFinderDataSource>
{
    public typealias Element = PFinderElement<T.Position>;
    
    //open list
    public var openList: BinaryPriorityQueue<Element>!;
    
    //visite list
    public var visiteList: [T.Position: Element]!;
    
    //goal point
    private var goal: T.Position!;
    
    //request
    public private(set) var dataSource: T;
    
    //init
    public init(dataSource: T)
    {
        self.dataSource = dataSource;
    }
}
extension AstarPFinder: PriorityPFinderType{}
extension AstarPFinder: PFinderProcessor
{
    public mutating func preparation(start: T.Position, goal: T.Position) {
        self.goal = goal;
        self.openList = BinaryPriorityQueue<Element>{return $0.f < $1.f;}
        self.visiteList = [:];
    }
    
    //search position
    public mutating func searchOf(position: T.Position, _ parent: Element?) -> Element?{
        print("WARN: =======================check walkable");
        
        let h = self.dataSource.heuristicOf(position, self.goal);
        guard let p = parent else{
            return Element(g: 0, h: h, position: position, parent: nil);
        }

        let g = p.g + self.dataSource.costBetween(p.position, and: position)
        guard let visited = self[position] else {
            return Element(g: g, h: h, position: position, parent: p);
        }
        guard !visited.isClosed && g < visited.g else {return nil;}

        var element = visited;
        element.setParent(p, g: g);
        guard let i = (self.openList.indexOf{return $0.position == element.position;})else{return nil;}
        self.openList.replaceElement(element, atIndex: i);
        self.visiteList[element.position] = element;
        return nil;
    }
}



//MARK: == DijkstraPFinder ==
public struct DijkstraPFinder<T: PFinderDataSource>
{
    public typealias Element = PFinderElement<T.Position>;
    
    //open list
    public var openList: BinaryPriorityQueue<Element>!;
    
    //visite list
    public var visiteList: [T.Position: Element]!;
    
    //goal point
    private var goal: T.Position!;
    
    //request
    public private(set) var dataSource: T;
    
    //init
    public init(dataSource: T)
    {
        self.dataSource = dataSource;
    }
}
extension DijkstraPFinder: PriorityPFinderType{}
extension DijkstraPFinder: PFinderMultiProcessor
{
    public mutating func preparation(start: T.Position, goal: T.Position) {
        self.goal = goal;
        self.openList = BinaryPriorityQueue<Element>{return $0.f < $1.f;}
        self.visiteList = [:];
    }
    
    //search position
    public mutating func searchOf(position: T.Position, _ parent: Element?) -> Element?{
        print("WARN: =======================check walkable");
        guard let p = parent else{
            return Element(g: 0, h: 0, position: position, parent: nil);
        }
        
        let g = p.g + self.dataSource.costBetween(p.position, and: position)
        guard let visited = self[position] else {
            return Element(g: g, h: 0, position: position, parent: p);
        }
        guard !visited.isClosed && g < visited.g else {return nil;}
        
        var element = visited;
        element.setParent(p, g: g);
        guard let i = (self.openList.indexOf{return $0.position == element.position;})else{return nil;}
        self.openList.replaceElement(element, atIndex: i);
        self.visiteList[element.position] = element;
        return nil;
    }
}

//MARK: == BreadthBestPFinder ==
public struct BreadthBestPFinder<T: PFinderDataSource>
{
    public typealias Element = PFinderElement<T.Position>;
    
    //open list
    public var openList: [Element]!;
    
    //visite list
    public var visiteList: [T.Position: Element]!;
    
    //current index
    private var currentIndex: Int = 0;
    
    //goal point
    private var goal: T.Position!;
    
    //request
    public private(set) var dataSource: T;
    
    //init
    public init(dataSource: T)
    {
        self.dataSource = dataSource;
    }
    
}
extension BreadthBestPFinder: PFinderMultiProcessor
{
    public mutating func popBest() -> Element? {
        return self.openList[self.currentIndex++];
    }
    
    public subscript(position: T.Position) -> Element? {
        set{
            guard let element = newValue else {return;}
            guard !element.isClosed else{
                self.visiteList[position] = element;
                return;
            }
            
            self.openList.append(element);
            self.visiteList[position] = element;
        }
        get{
            return self.visiteList[position];
        }
    }
    public mutating func preparation(start: T.Position, goal: T.Position) {
        self.goal = goal;
        self.openList = []
        self.visiteList = [:];
    }
    
    //search position
    public mutating func searchOf(position: T.Position, _ parent: Element?) -> Element?{
        print("WARN: =======================check walkable");
        guard let _ = self[position] else {
            guard let p = parent else{
                return Element(g: 0, h: 0, position: position, parent: nil);
            }
            return Element(g: 0, h: 0, position: position, parent: p);
        }
        return nil;
    }
}