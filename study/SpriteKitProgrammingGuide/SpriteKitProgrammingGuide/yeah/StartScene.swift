//
//  StartScene.swift
//  SpriteKitProgrammingGuide
//
//  Created by 173 on 15/5/15.
//  Copyright (c) 2015年 173. All rights reserved.
//

import Foundation
import SpriteKit;


/**
*  开始场景
*/
class StartScene: SKScene {
    
    //内容是否已经创建了
    private var contentCreated = false;
    
    override func didMoveToView(view: SKView) {
        if contentCreated {return }
        contentCreated = true;
        
        self.createContents();
    }
    
    /**
    创建内容
    */
    private func createContents()
    {
        self.backgroundColor = SKColor.blueColor();
        self.scaleMode = SKSceneScaleMode.AspectFill;
        self.addChild(startNode);
    }
    
    
    //开始node
    private var startNode:SKNode{
        let l = SKLabelNode(text: "Getting Start!");
        l.fontName = "Chalkduster";
        l.fontSize = 30;
        l.name = "startNode";
        l.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame));
        return l;
    }
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let node = self.childNodeWithName("startNode")
        {
            if(node.name != nil)
            {
                node.name = nil;
                
                let action = SKAction.sequence([
                    SKAction.moveByX(0, y: 100, duration: 0.5),
                    SKAction.scaleTo(2.0, duration: 0.25),
                    SKAction.waitForDuration(0.5),
                    SKAction.fadeOutWithDuration(0.25),
                    SKAction.removeFromParent()
                    ]);
                
                
                node.runAction(action){
                    let transitiongAction = SKTransition.doorsOpenVerticalWithDuration(0.5);
                    let shipScene = SpacesShipScene(size: self.size);
                    self.view?.presentScene(shipScene, transition: transitiongAction);
                }
            }
        }
    }
}