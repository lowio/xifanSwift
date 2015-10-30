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
    
    private var testPerformance:Bool = true;
    
    private func waitForTest()
    {
//        pathFinderTest();
//        commonTest();
        
        var abs = ABs();
        for i in 0...199
        {
            abs.source.append(i);
            
        }
        
        abs._shiftUp();
//        print(abs.source)
    }
}


struct ABs {
    var source:[Int] = []
    
    var ii = 0;
    
    mutating func _shiftUp()
    {
        guard source.count > 1 else{return;}
        self.source.removeAtIndex(self.source.count/2);
        self.source = self.source.sort();
    }
    
    mutating func shiftUp()
    {
        repeat{
            self.source.removeAtIndex(self.source.count/2);
            self.source = self.source.sort();
        }while self.source.count > 1
    }
}
