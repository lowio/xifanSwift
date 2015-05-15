//
//  SpacesShipScene.swift
//  SpriteKitProgrammingGuide
//
//  Created by 173 on 15/5/15.
//  Copyright (c) 2015年 173. All rights reserved.
//

import Foundation
import SpriteKit;

class SpacesShipScene: SKScene {
    
    private var contentCreated = false;
    
    private func createContents()
    {
        if contentCreated {return }
        contentCreated = true;
        
        self.backgroundColor = SKColor.blackColor();
        self.scaleMode = SKSceneScaleMode.AspectFill;
        
        let ship = newSpacesShip;
        ship.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame) - 150);
        self.addChild(ship);
        
        let repeatCreatRocks = SKAction.sequence([
            SKAction.runBlock(){
                newRock();
            },
            SKAction.waitForDuration(0.1, withRange: 0.15)
            
            ]);
        
        
        
        self.runAction(SKAction.repeatActionForever(repeatCreatRocks));
    }
    
    override func didMoveToView(view: SKView) {
        createContents();
    }
    
    override func didSimulatePhysics() {
        self.enumerateChildNodesWithName("rock"){(node, _) in
            if node.position.y < 0
            {
                node.removeFromParent();
            }
        }
    }
    
    //创建一个新的飞船
    private var newSpacesShip:SKNode{
        let node = SKSpriteNode(color: SKColor.grayColor(), size: CGSize(width: 64, height: 32));
        let hover = SKAction.sequence([
            SKAction.waitForDuration(1),
            SKAction.moveByX(100, y: 50, duration: 1),
            SKAction.waitForDuration(1),
            SKAction.moveByX(-100, y: -50, duration: 1)
            ]);
        let light = newLight;
        light.position = CGPoint(x: 0, y: 20);
        node.addChild(light);
        
        node.runAction(SKAction.repeatActionForever(hover));
        node.physicsBody = SKPhysicsBody(rectangleOfSize: node.size);
        node.physicsBody?.dynamic = false;
        return node;
    }
    
    //创建一个新的光
    private var newLight:SKNode{
        let node = SKSpriteNode(color: SKColor.yellowColor(), size: CGSize(width: 8, height: 8));
        let blink = SKAction.sequence([
            SKAction.fadeOutWithDuration(0.25),
            SKAction.fadeInWithDuration(0.25)
            ]);
        node.runAction(SKAction.repeatActionForever(blink));
        return node;
    }
    
    //创建一个新的rock
    private func newRock() -> SKNode
    {
        let node = SKSpriteNode(color: SKColor.brownColor(), size: CGSize(width: 8, height: 8));
        node.position = CGPoint(x: SpacesShipScene.randf(0, high: self.size.width), y: self.size.height - 50)
        node.name = "rock";
        node.physicsBody = SKPhysicsBody(rectangleOfSize: node.size);
        node.physicsBody?.usesPreciseCollisionDetection = true;
        self.addChild(node);
        return node;
    }
    
    
    
    //获取一个cgfloat类型的随机数（0-1）
    class func randf() -> CGFloat
    {
        return CGFloat(rand()) / CGFloat(RAND_MAX);
    }
    
    class func randf(low:CGFloat, high:CGFloat) -> CGFloat
    {
        return low + randf() * (high - low);
    }
}