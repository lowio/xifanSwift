//
//  GameScene.swift
//  AnimationDemo
//
//  Created by 叶贤辉 on 15/3/20.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var bearNode:SKSpriteNode!;
    var bearTextures:[SKTexture]!;
    let walkingActionName = "bearWalking";
    
    override func didMoveToView(view: SKView) {
        self.backgroundColor = SKColor.blackColor();
        
        let bearAltlas = SKTextureAtlas(named: "BearImages");
        let count:Int = bearAltlas.textureNames.count/2;
        var arr = [SKTexture]();
        for i in 1...count
        {
            let t = bearAltlas.textureNamed("bear\(i)");
            arr.append(t);
        }
        bearTextures = arr;
        let t = bearTextures[0];
        
        bearNode = SKSpriteNode(texture: t);
        bearNode.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame));
        self.addChild(bearNode);
        onWalking();
    }
    
    //散步
    private func onWalking()
    {
        bearNode.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(bearTextures, timePerFrame: 0.1, resize: false, restore: true)), withKey: walkingActionName);
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        let tu = touches.anyObject() as UITouch;
        let location = tu.locationInNode(self);
        
        var xs:CGFloat = 1;
        if location.x > CGRectGetMidX(self.frame)
        {
            xs = -1;
        }
        
        bearNode.xScale = fabs(bearNode.xScale) * xs;
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
