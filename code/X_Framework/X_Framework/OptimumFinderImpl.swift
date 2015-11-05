//
//  OptimumFinderImpl.swift
//  X_Framework
//
//  Created by 叶贤辉 on 15/10/23.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: == FinderElement ==
public struct FinderElement<T: Hashable>{
    //'self' is closed default false
    public var isClosed:Bool = false;
    
    //chain from
    public private (set) var parent: FinderChainable?;
    
    //weight f = g + h
    public private (set) var g, h, f:CGFloat;
    
    //point
    public private (set) var point: T;
    
    //init
    public init(g: CGFloat, h:CGFloat, point: T, parent: FinderChainable?)
    {
        self.g = g;
        self.h = h;
        self.f = g + h;
        self.point = point;
        self.parent = parent;
    }
}
extension FinderElement: FinderComparable{
    mutating public func setParent(parent: FinderChainable, g: CGFloat) {
        self.parent = parent;
        self.g = g;
        self.f = self.g + self.h;
    }
}
extension FinderElement: FinderChainable{}
extension FinderElement: Equatable{}
public func ==<T: Hashable>(lsh: FinderElement<T>, rsh: FinderElement<T>) -> Bool {return lsh == rsh;}



//MARK: == GreedyBestFirstFinder ==
public struct GreedyBestFirstFinder<T: FinderSingleGoalRequest>
{
    public typealias Request = T;
    
    //reqeust
    public private (set) var request: Request;
    
    //queue
    public var openList: BinaryPriorityQueue<Element>;
    
    //dic
    public var visitedList: [Element.Point: Element];
    
    public init(request: Request)
    {
        self.request = request;
        self.openList = BinaryPriorityQueue<Element>{return $0.h < $1.h;}
        self.visitedList = [:];
    }
}
//MARK: extension FinderWeightQueue
extension GreedyBestFirstFinder: FinderWeightQueue{}
//MARK: extension FinderSingleGoalProcessor
extension GreedyBestFirstFinder: FinderSingleGoalProcessor{}
//MARK: extension FinderProcessor
extension GreedyBestFirstFinder: FinderProcessor {
    
    public typealias Element = FinderElement<Request.Point>;
    
    public mutating func execute(request: Request) {
        self.request = request;
        self.openList = BinaryPriorityQueue<Element>{return $0.h < $1.h;}
        self.visitedList = [:];
        self.execute();
    }
    
    //explore successor point
    @warn_unused_result
    public mutating func exploreSuccessor(point: Element.Point, chainFrom: Element?) -> Element?
    {
        guard let _ = self.getVisitedElement(point) else {
            let ele = Element(g: CGFloat(), h: self.request.heuristicOf(point, self.request.goal), point: point, parent: chainFrom as? FinderChainable);
            self.openList.insert(ele);
            return ele;
        }
        return nil;
    }
}


//MARK: == DijkstraFinder ==
public struct DijkstraFinder<T: FinderMiltiGoalRequest>
{
    public typealias Request = T;
    
    //reqeust
    public private (set) var request: T;
    
    //queue
    public var openList: BinaryPriorityQueue<Element>;
    
    //dic
    public var visitedList: [Element.Point: Element];
    
    public init(request: Request)
    {
        self.request = request;
        self.openList = BinaryPriorityQueue<Element>{return $0.h < $1.h;}
        self.visitedList = [:];
    }

}
//MARK: extension FinderWeightQueue
extension DijkstraFinder: FinderWeightQueue{}
//MARK: extension FinderMultiGoalsProcessor
extension DijkstraFinder: FinderMultiGoalsProcessor{}
//MARK: extension FinderProcessor
extension DijkstraFinder: FinderProcessor {
    
    public typealias Element = FinderElement<Request.Point>;
    
    public mutating func execute(request: Request) {
        self.request = request;
        self.openList = BinaryPriorityQueue<Element>{return $0.h < $1.h;}
        self.visitedList = [:];
        self.execute();
    }
    
    //explore successor point
    @warn_unused_result
    public mutating func exploreSuccessor(point: Element.Point, chainFrom: Element?) -> Element?
    {
        guard let _ = self.getVisitedElement(point) else {
            var g:CGFloat = 0;
            if let cf = chainFrom{
                g = cf.g + self.request.costOf(cf.point, point);
            }
            let ele = Element(g: g, h: 0, point: point, parent: chainFrom as? FinderChainable);
            self.openList.insert(ele);
            return ele;
        }
        return nil;
    }
}

//MARK: == AstarFinder ==
public struct AstarFinder<T: FinderSingleGoalRequest>
{
    public typealias Request = T;
    
    //reqeust
    public private (set) var request: Request;
    
    //queue
    public var openList: BinaryPriorityQueue<Element>;
    
    //dic
    public var visitedList: [Element.Point: Element];
    
    public init(request: Request)
    {
        self.request = request;
        self.openList = BinaryPriorityQueue<Element>{return $0.h < $1.h;}
        self.visitedList = [:];
    }
}
//MARK: extension FinderWeightQueue
extension AstarFinder: FinderWeightQueue{}
//MARK: extension FinderSingleGoalProcessor
extension AstarFinder: FinderSingleGoalProcessor{}
//MARK: extension FinderProcessor
extension AstarFinder: FinderProcessor {
    public typealias Element = FinderElement<Request.Point>;
    
    public mutating func execute(request: Request) {
        self.request = request;
        self.openList = BinaryPriorityQueue<Element>{return $0.h < $1.h;}
        self.visitedList = [:];
        self.execute();
    }
    
    //explore successor point
    @warn_unused_result
    public mutating func exploreSuccessor(point: Element.Point, chainFrom: Element?) -> Element?
    {
        var g:CGFloat = 0;
        if let cf = chainFrom{
            g = cf.g + self.request.costOf(cf.point, point);
        }

        guard let visited = self.getVisitedElement(point) else {
            let h = self.request.heuristicOf(point, self.request.goal);
            let ele = Element(g: g, h: h, point: point, parent: chainFrom as? FinderChainable);
            self.openList.insert(ele);
            return ele;
        }

        guard !visited.isClosed && g < visited.g else{return nil;}
        let ele = Element(g: g, h: visited.h, point: point, parent: chainFrom as? FinderChainable);
        self.updateElement(ele);
        return ele;
    }
}
