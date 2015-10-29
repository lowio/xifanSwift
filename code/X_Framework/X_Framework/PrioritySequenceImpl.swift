//
//  PrioritySequenceImpl.swift
//  X_Framework
//
//  Created by 叶贤辉 on 15/10/29.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

//MARK: PriorityBinaryTree
struct PriorityBinaryTree<T: MutableCollectionType where T.Index == Int>
{
    //source
    private(set) var source: T;
    
    //branch maximum
    let branchMaximum: T.Index.Distance = 2;
    
    //treeIndex
    var treeIndex: _TreeType{return self;}
    
    //sort according to isOrderedBefore
    private (set) var isOrderedBefore: (T.Generator.Element, T.Generator.Element)->Bool;
    
    //init
    init(source: T, isOrderedBefore: (T.Generator.Element, T.Generator.Element)->Bool)
    {
        self.source = source;
        self.isOrderedBefore = isOrderedBefore;
    }
}

//extension SequenceType
extension PriorityBinaryTree: SequenceType
{
    func generate() -> T.Generator {
        return self.source.generate();
    }
}

//extension PriorityBinaryTree
extension PriorityBinaryTree: MutableIndexable
{
    var startIndex: T.Index {return self.source.startIndex;}
    
    var endIndex: T.Index {return self.source.endIndex;}
    
    subscript (position: T.Index) -> T.Generator.Element {
        set{
            self.source[position] = newValue;
        }
        get{
            return self.source[position];
        }
    }
}

//extension PrioritySequenceTreeType
extension PriorityBinaryTree: PrioritySequenceTreeType
{
    //trunk index
    func trunkIndexOf(branchIndex: T.Index) -> T.Index
    {
        return (branchIndex - 1) >> 1;
    }
    
    //branch index
    func branchIndexOf(trunkIndex: T.Index) -> T.Index
    {
        return (trunkIndex << 1) + 1;
    }
}

//extension PrioritySequenceConvertible
extension PriorityBinaryTree: PrioritySequenceConvertible
{
    typealias _TreeType = PriorityBinaryTree;
}

//MARK: PriorityBinaryArray
public struct PriorityBinaryArray<T>
{
//    //data source type
//    public typealias _DataSource = Array<T>;
    
    
    
    
    
    
}

////extension PrioritySequenceTreeType
//extension PriorityBinaryArray: PrioritySequenceType
//{
//    //count
//    public var count: Self.Index.Distance{return 0}
//    
//    //'self' is empty
//    public var isEmpaty: Bool{get}
//    
//    //append element and resort
//    public func insert(element: Generator.Element)
//    
//    //return(and remove) first element and resort
//    public func popBest() -> Self.Generator.Element?
//    
//    //update element and resort
//    public func updateElement(element: Self.Generator.Element, atIndex: Self.Index)
//}
