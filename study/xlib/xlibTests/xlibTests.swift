//
//  xlibTests.swift
//  xlibTests
//
//  Created by 173 on 15/8/31.
//  Copyright (c) 2015年 yeah. All rights reserved.
//

import UIKit
import XCTest
import xlib;

class xlibTests: XCTestCase {
    
    
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
//        testJsonParser();
        testPriorityQueue()
        
        
        
        // This is an example of a functional test case.
//        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
//            testPriorityQueue()
        }
    }
    
//    func testPriorityQueue()
//    {
//        
//        var q = PriorityQueue<(Int, Int)>(){$0.0.0 > $0.1.0}
//
//        for i in 0...49
//        {
//            //            let temp = Int(arc4random() % 100);
//            let temp = 1;
//            q.push((temp, i));
//        }
//        
//        
//        println(q)
//        
//        while(!q.empty)
//        {
//            println(q.pop());
//        }
//    }
    
}
