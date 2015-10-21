//
//  PriorityQueue.swift
//  X_Framework
//
//  Created by 173 on 15/10/21.
//  Copyright © 2015年 yeah. All rights reserved.
//

import Foundation

protocol PriorityCollectionType
{
    //element Type
    typealias _Element: CollectionType;
    
    //element count
    var count:Int{get}
    
    //element count == 0
    var isEmpty:Bool{get}
    
    //append element and resort
    mutating func append(newElement: Self._Element)
    
    //remove first element and resort
    mutating func removeFirst() -> Self._Element?
    
    //update element and resort
    mutating func update(newElement: Self._Element, atIndex: Int)
    
    //rebuild queue use source
    mutating func rebuild()
}