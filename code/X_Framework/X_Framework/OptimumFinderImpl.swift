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
    
    //g score, real cost from start point to 'self' point
    public var g: CGFloat;
    
    //weight f = g + h
    public private (set) var h:CGFloat;
    
    //point
    public private (set) var point: T;
    
    init(g: CGFloat, h:CGFloat, point: T)
    {
        self.g = g;
        self.h = h;
        self.point = point;
    }
}
extension FinderElement: FinderComparable{
    public var f: CGFloat{return self.g + self.h;}
}
public func ==<T: Hashable>(lsh: FinderElement<T>, rsh: FinderElement<T>) -> Bool {return lsh == rsh;}
public func > <T: Hashable>(lsh: FinderElement<T>, rsh: FinderElement<T>) -> Bool{return lsh.f > rsh.f;}
public func < <T: Hashable>(lsh: FinderElement<T>, rsh: FinderElement<T>) -> Bool{return lsh.f < rsh.f;}




//MARK: == BreadFirstFinder ==
public struct BreadFirstFinder<T: Hashable> {
    
}
extension BreadFirstFinder: OptimumFinder
{
    public typealias Element = FinderElement<T>;
    
    //get neighbors
    public func getNeighbors(around point: Element._Point) -> [Element._Point] {
        return [];
    }
    
    //get cost from sub point to point
    public func getCost(subPoint sp: Element._Point, toPoint tp: Element._Point) -> CGFloat {
        return 0;
    }
    
    //point is valid
    public func pointIsValid(point: Element._Point) -> Bool {
        return true;
    }
    
    //get heuristic
    public func getHeuristic(from: Element._Point, toPoint: Element._Point) -> CGFloat {
        return 0;
    }
    
    
    
    //create element
    public func createElement(g: CGFloat, h:CGFloat, point: Element._Point, chainFrom: Element?) -> Element {
        return Element(g: 0, h: 0, point: point);
    }
    
    //get visited element of point
    public func visitedElementOf(point: Element._Point) -> Element? {
        return nil;
    }
    
    //set element visited
    public mutating func visitedElement(element: Element) {
        
    }
    
    //set element closed
    public mutating func closedElement(element: Element) {
        
    }
    
    //pop next element
    public mutating func popNext() -> Element? {
        return nil;
    }
    
    //insert element
    public mutating func insert(element: Element) {
        
    }
    
    //update visited element
    public mutating func updateVisited(element: Element) {
        
    }
    
    
    //completion
    public mutating func completion(endElement: Element) {
        
    }
}


////MARK: BreadthFirst finder queue
//public struct FinderBreadthFirstQueue<Element: FinderComparable> {
//    
//    //key came from value
//    private(set) var camefrom: [Element._Point: Element];
//    
//    //opened list
//    private(set)var openedList: [Element];
//    
//    //last pop element
//    private var lastPop: Element?;
//    
//    //current index
//    private var currentIndex:Int = 0;
//    
//    init()
//    {
//        self.camefrom = [:];
//        self.openedList = [];
//    }
//}
//extension FinderBreadthFirstQueue: FinderQueue
//{
//    
//    //if point is visited return element else return nil
//    public func getVisitedElementAt(point: Element._Point) -> Element?
//    {
//        return self.camefrom[point];
//    }
//    
//    //set element's point closed and update it in 'Self'
//    mutating public func setPointClosedOf(element: Element)
//    {
//        self.camefrom[element.point!] = element;
//    }
//    
//    //set element's point visited and update it in 'Self'
//    mutating public func setPointVisitedOf(element: Element)
//    {
//        self.camefrom[element.point!] = element;
//    }
//    
//    //pop optimum element
//    mutating public func popFirstElement() -> Element?
//    {
//        guard currentIndex < self.openedList.count else{return nil;}
//        lastPop = self.openedList[currentIndex++];
//        return lastPop;
//    }
//    
//    //appen element
//    mutating public func appendElement(element: Element)
//    {
//        self.openedList.append(element);
//    }
//    
//    //update element
//    mutating public func updateElement(element: Element) -> Bool
//    {
//        guard let index = (self.openedList.indexOf{return element.point! == $0.point!})else{return false;}
//        self.openedList[index] = element;
//        return true;
//    }
//    
//    //all visited point
//    public func visitedPointsInOrder() -> [Element._Point]
//    {
//        return self.openedList.map{
//            return $0.point!
//        }
//    }
//}
//extension FinderBreadthFirstQueue where Element: Equatable
//{
//    //update element
//    mutating func updateElement(element: Element) -> Bool
//    {
//        guard let index = (self.openedList.indexOf(element))else{return false;}
//        self.openedList[index] = element;
//        return true;
//    }
//}
//
//
//
////MARK: optimum finder 2d
//public struct OFinder<T: FinderComparable>
//{
//}
//extension OFinder: OptimumFinder
//{
//    //element type
//    public typealias _Element = T;
//}


