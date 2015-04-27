//
//  SwiftTrisDelegate.swift
//  SwiftTris
//
//  Created by 叶贤辉 on 15/2/3.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import Foundation

//游戏delegate
protocol SwiftTrisDelegate
{
    
    //下一个
    func next(manager:SwiftTrisManager)
    
    //游戏结束
    func gameOver(manager:SwiftTrisManager)
    
    //降落
    func fall(manager:SwiftTrisManager)
    
}