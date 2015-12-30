//
//  X_FrameworkTests.swift
//  X_FrameworkTests
//
//  Created by xifanGame on 15/9/17.
//  Copyright © 2015年 yeah. All rights reserved.
//

import XCTest
@testable import X_Framework

class X_FrameworkTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFramework()
    {
        if testPerformance
        {
            self.measureBlock{
                self.waitForTest();
            }
        }
        else
        {
            waitForTest();
        }
    }
    
    private var testPerformance:Bool = true;
    
    private func waitForTest()
    {
//        pathFinderTest();
//        collectionNDTest();
//        priorityQueueTest();
        
        var s = S();
        for _ in 0...9999{
//            s.test1();
            s.test2();
        }
        print(s.a.count);
    }
}


struct S {
    var a: [Int] = [];
    mutating func test1(){
        self.a = [];
        for i in 0...999{
            self.a.append(i);
        }
    }
    
    mutating func test2(){
        var b: [Int] = [];
        for i in 0...999{
            b.append(i);
        }
        self.a = b;
    }
    
    
}



