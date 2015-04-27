//
//  GameScene.swift
//  SwiftTris
//
//  Created by 叶贤辉 on 15/1/28.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import SpriteKit

let intervalLowest = NSTimeInterval(600)

class GameScene: SKScene {
    
    var tick:(() -> ())?
    
    var tickInterval = intervalLowest
    
    var lastTick:NSDate?
    
    //纹理缓存
    var textureCache = Dictionary<String, SKTexture>()
    
    //gamelayer
    var gameLayer:SKNode = SKNode()
    
    //nodelayer
    var nodeLayer = NodeLayer()
    let layerPos = CGPoint(x: 6, y: -6)
    let blockSize:CGFloat = 20.0
    
    
    override init(size: CGSize) {
        super.init(size: size)
        anchorPoint = CGPoint(x: 0, y: 1)
        
        let bg = SKSpriteNode(imageNamed: "background")
        bg.anchorPoint = CGPoint(x: 0, y: 1)
        bg.position = CGPoint(x: 0, y: 0)
        self.addChild(bg)
        
        
        addChild(gameLayer)
        

        nodeLayer.position = layerPos
        gameLayer.addChild(nodeLayer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if lastTick == nil
        {
            return
        }
        
        var timePassed = lastTick!.timeIntervalSinceNow * -1000.0
        if timePassed > tickInterval
        {
            lastTick = NSDate()
            tick?()
        }
    }
    
    func tickStart()
    {
        lastTick = NSDate()
    }
    
    
    func tickStop()
    {
        lastTick = nil
    }
    
}
