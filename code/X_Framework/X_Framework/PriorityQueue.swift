//
//  PriorityQueue.swift
//  X_Framework
//
//  Created by yeah on 15/10/28.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: == HeapIndexGenerator ==
public protocol HeapIndexGeneratorType: GeneratorType
{
    //next index of index
    func nextIndexOf(index: Self.Element) -> Self.Element
}

//*********************************************************************************************************************
//*********************************************************************************************************************

//MARK: == HeapTranslatorType ==
public protocol HeapTranslatorType: CollectionType
{
    //trunk index generator type
    typealias TIG: HeapIndexGeneratorType;
    
    //branch index generator type
    typealias BIG: HeapIndexGeneratorType;
    
    //MARK: properties
    //============================= properties ===================================
    
    //sort according to isOrderedBefore
    var isOrderedBefore: (Self.Generator.Element, Self.Generator.Element) -> Bool {get}
    
    //subscript
    subscript(position: Self.Index) -> Self.Generator.Element{get set}
    
    //MARK: functions
    //============================= functions ===================================
    
    //trunk generator
    func trunkIndexGenerate(index: Self.Index) -> Self.TIG
    
    //branch generator
    func branchIndexGenerate(index: Self.Index) -> Self.BIG
    
    //shift up element at index
    mutating func shiftUp(index: Self.Index)
    
    //shift down element at index
    mutating func shiftDown(index: Self.Index)
    
    //priority sequence use isOrderedBefore function
    mutating func build()
}
extension HeapTranslatorType where Self.TIG.Element == Self.Index, Self.BIG.Element == Self.Index
{
    //shift up element at index
    public mutating func shiftUp(index: Self.Index)
    {
        //shift element
        let shiftElement = self[index];
        
        //shift index
        var shiftIndex = index;
        
        //trunk generator
        var tg = self.trunkIndexGenerate(index);
        
        //shift up
        repeat{
            //if has trunk index continue otherwise break;
            guard let trunkIndex = tg.next() else {break;}
            let trunkElement = self[trunkIndex];
            
            //compare: if shiftElement is better swap, otherwise return;
            guard self.isOrderedBefore(shiftElement, trunkElement) else {break;}
            self[shiftIndex] = self[trunkIndex];
            self[trunkIndex] = shiftElement;
            shiftIndex = trunkIndex;
        }while true
    }
    
    //shift down element at index
    public mutating func shiftDown(index: Self.Index)
    {
        //shift element
        let shiftElement = self[index];
        
        //trunk index
        var trunkIndex = index;
        
        repeat{
            //shift index
            var shiftIndex = trunkIndex;
            
            //branch index generator
            var bg = branchIndexGenerate(trunkIndex);
            var branchIndex = bg.next();
            
            //repeat branch elements, make shiftIndex as best branchIndex
            repeat{
                if let bi = branchIndex where self.isOrderedBefore(self[bi], self[shiftIndex]){
                    shiftIndex = bi;
                }
                branchIndex = bg.next();
            }while branchIndex != nil
            
            //if shiftIndex != trunkIndex swap otherwise return;
            guard shiftIndex != trunkIndex else{break;}
            self[trunkIndex] = self[shiftIndex];
            self[shiftIndex] = shiftElement;
            
            //shift index as trunk index
            trunkIndex = shiftIndex;
        }while true;
    }
    
    //priority sequence use isOrderedBefore function
    public mutating func build()
    {
        guard self.count > 1 else {return;}
        var tg = trunkIndexGenerate(self.endIndex.advancedBy(-1));
        
        var _index = tg.next()!;
        repeat{
            self.shiftDown(_index);
            _index = _index.advancedBy(-1);
        }while self.startIndex.distanceTo(_index) > -1
    }
}

//*********************************************************************************************************************
//*********************************************************************************************************************
public protocol PriorityQueueType: CollectionType
{
    //append element and resort
    mutating func insert(element: Self.Generator.Element)
    
    //return(and remove) first element and resort
    mutating func popBest() -> Self.Generator.Element?
    
    //replace element at index
    mutating func replaceElement(element: Self.Generator.Element, atIndex: Self.Index)
}

//*********************************************************************************************************************
//*********************************************************************************************************************
//MARK:======== Impl ========
//======================================== implement =================================================

//MARK: == BinaryTrunkIndexGenerator ==
public struct BinaryTrunkIndexGenerator
{
    //current index
    private var index: Int;
    
    //end index
    private let endIndex: Int;
    
    //init
    public init(_ index: Int, _ endIndex:Int)
    {
        self.index = index;
        self.endIndex = endIndex;
    }
}
extension BinaryTrunkIndexGenerator: HeapIndexGeneratorType
{
    //next trunk index of index
    public func nextIndexOf(index: Int) -> Int {return (index - 1) >> 1;}
    
    //next trunk element
    public mutating func next() -> Int? {
        guard self.index > self.endIndex else{return nil;}
        self.index = self.nextIndexOf(self.index);
        return self.index;
    }
}

//MARK: == BinaryBranchIndexGenerator ==
public struct BinaryBranchIndexGenerator
{
    //branch size
    private let branchSize = 2;
    
    //end index
    private let endIndex: Int;
    
    //current index
    private var index: Int;
    
    private var bc: Int;
    
    //init
    public init(_ index: Int, _ endIndex:Int)
    {
        self.index = index;
        self.endIndex = endIndex;
        self.bc = self.branchSize;
        self.index = self.nextIndexOf(index);
    }
}
extension BinaryBranchIndexGenerator: HeapIndexGeneratorType
{
    //next branch
    public mutating func next() -> Int? {
        guard self.bc > 0 && self.index < self.endIndex else{return nil;}
        let i = self.index;
        self.index = self.index.successor();
        self.bc--;
        return i;
    }
    
    //next branch index of index
    public func nextIndexOf(index: Int) -> Int {return index << 1 + 1;}
}

//*********************************************************************************************************************
//*********************************************************************************************************************

//MARK: == BinaryPriorityQueue ==
public struct BinaryPriorityQueue<T> {
    
    //MARK: properties
    //============================= properties ===================================
    
    //sort according to isOrderedBefore
    private(set) public var isOrderedBefore: (T, T) -> Bool;
    
    //source
    private(set) var source: [T];
    
    //init
    public init(source: [T], isOrderedBefore: (T, T) -> Bool)
    {
        self.isOrderedBefore = isOrderedBefore;
        self.source = source;
        self.build();
    }
    
    //init
    public init(isOrderedBefore: (T, T) -> Bool)
    {
        self.init(source: [], isOrderedBefore: isOrderedBefore);
    }
}
extension BinaryPriorityQueue where T: Comparable
{
    //minimum heap
    public init(minimum source: [T] = [])
    {
        self.init(source: source){return $0 > $1;}
    }
    
    //maximum heap
    public init(maximum source: [T] = [])
    {
        self.init(source: source){return $0 < $1;}
    }
}
//MARK: extension CollectionType
extension BinaryPriorityQueue: CollectionType
{
    //start index
    public var startIndex: Int{return 0;}
    
    //end index
    public var endIndex: Int{return self.source.endIndex;}
    
    //count
    public var count: Int{return self.source.count;}
    
    //'self' is empty
    public var isEmpty: Bool{return self.source.isEmpty}
    
    //subscript
    public subscript(position: Int) -> T{
        set{
            self.source[position] = newValue;
        }
        get{
            return self.source[position];
        }
    }
}
//MARK: extension HeapTranslatorType
extension BinaryPriorityQueue: HeapTranslatorType
{
    //trunk generator
    public func trunkIndexGenerate(index: Int) -> BinaryTrunkIndexGenerator
    {
        return BinaryTrunkIndexGenerator(index, self.startIndex);
    }
    
    //branch generator
    public func branchIndexGenerate(index: Int) -> BinaryBranchIndexGenerator
    {
        return BinaryBranchIndexGenerator(index, self.endIndex);
    }
    
    //shift up element at index
    public mutating func shiftUp(index: Int)
    {
        //shift element
        let shiftElement = self[index];
        
        //shift index
        var shiftIndex = index;
        
        //trunk generator
        var tg = self.trunkIndexGenerate(index);
        
        //shift up
        repeat{
            //if has trunk index continue otherwise break;
            guard let trunkIndex = tg.next() else {break;}
            let trunkElement = self[trunkIndex];
            
            //compare: if shiftElement is better swap, otherwise return;
            guard self.isOrderedBefore(shiftElement, trunkElement) else {break;}
            self[shiftIndex] = self[trunkIndex];
            self[trunkIndex] = shiftElement;
            shiftIndex = trunkIndex;
        }while true
    }
    
    //shift down element at index
    public mutating func shiftDown(index: Int)
    {
        //shift element
        let shiftElement = self[index];
        
        //trunk index
        var trunkIndex = index;
        
        repeat{
            //shift index
            var shiftIndex = trunkIndex;
            
            //branch index generator
            var bg = branchIndexGenerate(trunkIndex);
            var branchIndex = bg.next();
            
            //repeat branch elements, make shiftIndex as best branchIndex
            repeat{
                if let bi = branchIndex where self.isOrderedBefore(self[bi], self[shiftIndex]){
                    shiftIndex = bi;
                }
                branchIndex = bg.next();
            }while branchIndex != nil
            
            //if shiftIndex != trunkIndex swap otherwise return;
            guard shiftIndex != trunkIndex else{break;}
            self[trunkIndex] = self[shiftIndex];
            self[shiftIndex] = shiftElement;
            
            //shift index as trunk index
            trunkIndex = shiftIndex;
        }while true;
    }
    
    //priority sequence use isOrderedBefore function
    public mutating func build()
    {
        guard self.count > 1 else {return;}
        var tg = self.trunkIndexGenerate(self.count - 1);
        
        var _index = tg.next()!;
        repeat{
            self.shiftDown(_index);
            _index = _index.advancedBy(-1);
        }while self.startIndex.distanceTo(_index) > -1
    }
}
extension BinaryPriorityQueue: PriorityQueueType
{
    //append element and resort
    mutating public func insert(element: T)
    {
        self.source.append(element);
        self.shiftUp(self.endIndex.predecessor());
    }
    
    //return(and remove) first element and resort
    mutating public func popBest() -> T?
    {
        if(self.isEmpty){return nil;}
        let first = self.source[0];
        let end = self.source.removeLast();
        guard !self.isEmpty else{return first;}
        self.source[0] = end;
        self.shiftDown(self.startIndex);
        return first;
    }
    
    //replace element at index
    public mutating func replaceElement(element: T, atIndex: Int)
    {
        self[atIndex] = element;
        
        var tg = self.trunkIndexGenerate(atIndex);
        
        //if element is better shiftup otherwise shiftdown
        let trunkIndex = tg.next()!;
        guard self.isOrderedBefore(element, self[trunkIndex]) else{
            self.shiftUp(atIndex);
            return;
        }
        self.shiftDown(atIndex);
    }
}