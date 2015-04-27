//
//  GameObjectNode.swift
//  UberJump
//
//  Created by 叶贤辉 on 15/4/22.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import SpriteKit

//碰撞类型
struct CollisionCategoryBitmask {
    static let Player:UInt32 = 0x00;
    static let Star:UInt32 = 0x01;
    static let Platform:UInt32 = 0x02;
}


class GameObjectNode: SKNode {
   
    /**
    发生碰撞
    抽象方法 子类需要重写
    :param: player 发生碰撞的node
    
    :returns: 碰撞是否有效
    */
    func collisionWithPlayer(player:SKNode) -> Bool
    {
        return false;
    }
    
    /**
    检测node是否需要回收(每帧检测);
    
    :param: playerY player的y轴位置
    */
    func checkNodeRecycle(playerY:CGFloat)
    {
        if playerY > self.position.y + 300
        {
            self.removeFromParent();
        }
    }
    
    
    
}



/**
*  星星
*/
class StarNode: GameObjectNode {
    
    override func collisionWithPlayer(player: SKNode) -> Bool {
        player.physicsBody?.velocity = CGVector(dx:player.physicsBody!.velocity.dx, dy:400);
        
        //        runAction(starSound){
        self.removeFromParent();
        //        }
        
        return true;
    }
    
    /**
    创建一个星星
    
    :param: position 星星的位置
    :param: type     星星的类型
    
    :returns: star node
    */
    class func createStarAtPosition(position:CGPoint, ofType type:StarType) -> SKNode
    {
        let star = StarNode();
        let pos = CGPoint(x: position.x, y: position.y);
        star.name = "NODE_STAR";
        star.position = pos;
        
        let sprite = SKSpriteNode(imageNamed: type.spriteName);
        star.addChild(sprite);
        
        star.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2);
        star.physicsBody?.dynamic = false;
        
        star.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Star;
        star.physicsBody?.collisionBitMask = 0;
        return star;
        
    }
    
    //    let starSound = SKAction.playSoundFileNamed("../StarPing.wav", waitForCompletion: false);
}

/**
star type

- Normal:  normal
- Special: special
*/
enum StarType:Int
{
    case Normal = 0
    case Special
    
    //不用类型对应的sprite file name
    var spriteName:String {
        switch self
        {
        case .Normal:
            return "Star";
        case .Special:
            return "StarSpecial";
        }
    }
}

/**
platform

- Normal: normal platform
- Break:  break platform
*/
enum PlatformType:Int
{
    case Normal = 0
    case Break
    
    
    var spriteName:String {
        switch self
        {
        case .Normal:
            
            return "Platform";
        case .Break:
            return "PlatformBreak";
        }
    }
}


class PlatFormNode: GameObjectNode {
    
    //platform 类型
    var platformType:PlatformType!;
    
    override func collisionWithPlayer(player: SKNode) -> Bool {
        if player.physicsBody?.velocity.dy < 0
        {
            player.physicsBody?.velocity = CGVector(dx: player.physicsBody!.velocity.dx, dy: 250);
            
            if self.platformType == .Break
            {
                self.removeFromParent();
            }
        }
        return false;
    }
    
    
    //创建一个platform node
    class func createPlatformAtPosition(position:CGPoint, ofType type:PlatformType) -> SKNode
    {
        let node = PlatFormNode();
        node.position = position;
        node.platformType = type;
        
        let sprite = SKSpriteNode(imageNamed: type.spriteName);
        node.addChild(sprite);
        
        node.physicsBody = SKPhysicsBody(rectangleOfSize: sprite.size);
        node.physicsBody?.dynamic = false;
        node.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Platform;
        node.physicsBody?.collisionBitMask =  0;
        
        return node;
    }
}
