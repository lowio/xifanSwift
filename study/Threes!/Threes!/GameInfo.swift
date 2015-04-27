//
//  GameInfo.swift
//  Threes!
//
//  Created by 叶贤辉 on 15/3/6.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import Foundation
import SpriteKit
//=====================playerinfo========================

struct PlayerInfo {
    
    //得分 当前级别
    var score = 0
    var level = 2
    
    init()
    {
        reset()
    }
    
    //重置 积分和当前最高级别
    mutating func reset()
    {
        self.score = 0
        self.level = 2
    }
    
    static var instance = PlayerInfo()
}

//=====================GameInfo========================


struct GameInfo {
    
    //行列总数
    var columns, rows:Int
    
    //scene size
    var sceneSize:CGSize
    
    //节点尺寸
    var nodeSize:CGSize
    
    init()
    {
        self.columns = 0
        self.rows = 0
        self.sceneSize = CGSize()
        self.nodeSize = CGSize()
    }
    
    //唯一引用
    static var instance = GameInfo()
}

extension GameInfo
{
    //重置 行列 重置 各种尺寸
    mutating func reset(columns:Int, rows:Int, sceneSize:CGSize, nodeSize:CGSize)
    {
        self.columns = columns
        self.rows = rows
        self.sceneSize = sceneSize
        self.nodeSize = nodeSize
        GameInfo.instance = self
    }
}