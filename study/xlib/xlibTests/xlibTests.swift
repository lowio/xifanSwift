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


//struct AA<T>:AAProtocol {
//    typealias bb = T
//    
//    
//    func getIndex<E : Equatable where bb:Equatable>(e: E) {
//        
//    }
//}



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
        self.measureBlock() {self.testExample()}
    }
    
    func testExample() {
//        jsonTest();
        priorityQueueTest();
//        pathFindTest();
    }
    
    
    
    
   
    
    
    //XPriorityQueue test
    func priorityQueueTest()
    {
//        var q = XPriorityQueue<Int>{$0.0 >= $0.1 ? 1 : -1}
//        let c = 100;
//        
//        for i in 0...c
//        {
//            let temp = Int(arc4random() % 500);
//            let e = q.pop();
//            
//            for j in 0...3
//            {
//                q.push(temp);
//            }
//        }
        
        var arr = [Int]();
        for i in 0...14
        {
            arr.append(Int(arc4random() % 1000));
        }
        println(arr);
        var q = XPriorityQueue<Int>(source: arr){$0.0 >= $0.1 ? 1 : -1};
        arr.sort{$0.0 > $0.1}
        
        
        
        while(!q.isEmpty)
        {
            let e = q.pop()!;
            
            let e2 = arr.removeLast();
            println("\(e)-\(e2)=\(e - e2) ");
//            println(e)
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
