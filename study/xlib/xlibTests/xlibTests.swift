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
    
    
    func testPerformanceExample() {
//        self.measureBlock() {self.testExample()}
    }
    
    func testExample() {
//        jsonTest();
//        priorityQueueTest();
        pathFindTest();
    }
    
    
    
    
   
    
    
    //XPriorityQueue test
    func priorityQueueTest(testRebuild:Bool = false)
    {
        var queue:XPriorityQueue<Int>;
        if(testRebuild)//测试创建优先队列
        {
            var sortArray = [Int]();
            for i in 0...100
            {
                sortArray.append(Int(arc4random() % 1000));
            }
            queue = XPriorityQueue<Int>(sequence: sortArray){$0.0 >= $0.1};
            sortArray.sort{$0 > $1}
            while !queue.isEmpty
            {
                let e1 = queue.pop()!;
                let e2 = sortArray.removeLast();
                println("\(e1)-\(e2)=\(e1 - e2) ");
            }
        }
        else
        {   //测试优先队列效率
            queue = XPriorityQueue<Int>{$0 >= $1}
            let c = 100;
            for i in 0...c
            {
                let temp = Int(arc4random() % 500);
                if(!queue.isEmpty){queue.pop();}
                
                for j in 0...3
                {
                    queue.push(temp);
                }
            }
            
            while(!queue.isEmpty)
            {
                let e = queue.pop()!;
                println(e)
            }
        }
        
        
        
        
        
    }
    
    
    //XJSON test
    private func jsonTest()
    {
        TestUtils.getTopAppsDataFromFileWithSuccess(){
            (jsd) -> Void in
            let jsonParser = XJSON(data: jsd);
            let d = jsonParser["feed"]["author"]["uri"]["label"] as XJSON
//            let d = jsonParser["feed"]["author"] as XJSON
            let v = d.stringValue;
        };
    }
    
    
}
