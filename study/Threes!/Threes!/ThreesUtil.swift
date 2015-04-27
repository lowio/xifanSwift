//
//  ThreesUtil.swift
//  Threes!
//
//  Created by 叶贤辉 on 15/2/25.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import SpriteKit

class ThreesUtil {
    
    //获取 0..<max 的随机数
    class func getRandom(max:Int) -> Int
    {
        return Int(arc4random())%max
    }
    
    //获取随即值
    class func getRandom<T>(array:Array<T>) -> T
    {
        let index = getRandom(array.count)
        return array[index]
    }
    
    //画圆角矩形
    class func drawRoundedRects(rects:[CGRect]) -> CGPathRef
    {
        let p = CGPathCreateMutable()
        for rect in rects
        {
            CGPathAddRoundedRect(p, nil, rect, GameConfig.cornerRadius, GameConfig.cornerRadius)
        }
        CGPathCloseSubpath(p)
        return p
    }
}