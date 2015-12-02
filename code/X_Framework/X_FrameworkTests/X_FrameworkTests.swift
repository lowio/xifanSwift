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
    
    var dic:[Int: Int] = [:]
    
    func testFramework()
    {
        tempTest();
        
        for i in 0...4000
        {
            dic[i] = i;
        }
        
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
        pathFinderTest();
//        commonTest();
    }
}


struct S {
    var a = 0;
    var b = 0;
    
    mutating func setA(a:Int){
        self.a = a;
    }
    
    mutating func setB(b: Int){
        self.b = b;
    }
    
    mutating func setAB(a: Int, _ b: Int){
        self.a = a;
        self.b = b;
    }
}

