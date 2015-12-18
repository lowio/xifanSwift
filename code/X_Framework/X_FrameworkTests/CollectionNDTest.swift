//
//  CollectionNDTest.swift
//  X_Framework
//
//  Created by xifanGame on 15/9/17.
//  Copyright © 2015年 yeah. All rights reserved.
//

import UIKit
@testable import X_Framework;

func collectionNDTest()
{
    let columns = 4;
    let rows = 3;
//    var nd = Array2D<Int?>(columns: columns, rows: rows, repeatValue: 0);
    var nd = Array2D<Int>(columns: columns, rows: rows, repeatValue: 0);
    print(nd);
    var i = 0;
    for r in 0..<rows
    {
        for c in 0..<columns
        {
            nd[c, r] = i++;
        }
    }
    print(nd);
    print(nd.count)
    nd[1, 1] = 99;
//    nd[3, 2] = nil;
    
    let p = nd.positionOf{
        return 99 == $0
    }
    print(nd, p);
//    nd = Array2D<Int>(columns: nd.columns, rows: nd.rows, repeatValue: 0, values: [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]);
    nd = Array2D<Int>(columns: nd.columns, rows: nd.rows, repeatValue: 0, values: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]);
    nd[3,2] = 99;
    print(nd);
    
    
    let a = Array<Int>(nd);
    print(a);
}