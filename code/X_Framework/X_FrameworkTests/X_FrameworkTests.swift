//
//  X_FrameworkTests.swift
//  X_FrameworkTests
//
//  Created by 173 on 15/9/17.
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
        tempTest();
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
    
    private var testPerformance:Bool = false;
    private func waitForTest()
    {
        pathFinderTest();
//        commonTest();
    }
}