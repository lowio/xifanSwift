//
//  GameScene.swift
//  UberJump
//
//  Created by 叶贤辉 on 15/4/21.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    
    //缩放比率
    var scaleRate:CGFloat!;
    
    //标准宽度（根据素材决定）
    let standardWidth:CGFloat = 320;
    
    //组成背景的素材个数
    let bgImageCount = 20;
    
    //背景layer
    var backgroudLayer:SKNode!;
    
    //前景 layer
    var foreLayer:SKNode!;
    
    //player
    var player:SKNode!;
    
    //ui layer
    var hudLayer:SKNode!;
    
    //点击开始 的提示
    let tapToStartNode:SKNode = SKSpriteNode(imageNamed: "TapToStart");
    
    override init(size: CGSize) {
        super.init(size: size);
        backgroundColor = SKColor.whiteColor();
        self.scaleRate = size.width/self.standardWidth;
        backgroudLayer = createBackgroundLayer();
        
       
        
        self.addChild(backgroudLayer);
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -2);
        physicsWorld.contactDelegate = self;
        
        player = createPlayer();
        foreLayer = SKNode();
        foreLayer.addChild(player);
        self.addChild(foreLayer);
        player.physicsBody?.dynamic = false;
        
        hudLayer = SKNode();
        tapToStartNode.position = CGPoint(x: self.size.width / 2, y: 180);
        hudLayer.addChild(tapToStartNode);
        self.addChild(hudLayer);
        
        
        let star = createStarAtPosition(CGPoint(x: 160, y: 220), ofType: StarType.Special);
        foreLayer.addChild(star)
        
        let platform = PlatFormNode.createPlatformAtPosition(CGPoint(x: 160 * scaleRate, y: 320), ofType: .Normal);
        foreLayer.addChild(platform);
    }
    
    
    /**
    create backgroud node
    attention: 资源加载一定要add file to xx 才能使用 而不是直接拖动后不管
    :returns: backgroud node
    */
    private func createBackgroundLayer() -> SKNode
    {
        let node = SKNode();
        
        let centerX:CGFloat = self.size.width / 2;
        var bgItemPosy:CGFloat = 0;
        for i in 0..<bgImageCount
        {
            
            //%02d  --> 有两行如果替换的值只有一行则自动填充0
            let bgItem = SKSpriteNode(imageNamed: String(format: "Background%02d", i + 1));
            bgItem.anchorPoint = CGPoint(x: 0.5, y: 0);
            bgItem.setScale(self.scaleRate);
            bgItem.position = CGPoint(x: centerX, y: bgItemPosy);
            node.addChild(bgItem);
            bgItemPosy += bgItem.size.height;
        }
        
        return node;
    }
    
    /**
    create player node
    
    :returns: player node
    */
    private func createPlayer() -> SKNode
    {
        let node = SKNode();
        node.position = CGPoint(x: self.size.width / 2, y: 80);
        
        let sprite = SKSpriteNode(imageNamed: "Player");
        node.addChild(sprite);
        
        node.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2);
        node.physicsBody?.dynamic = true;
        node.physicsBody?.allowsRotation = false;
        node.physicsBody?.restitution = 1;
        node.physicsBody?.friction = 0;
        node.physicsBody?.angularDamping = 0;
        node.physicsBody?.linearDamping = 0;
        
        node.physicsBody?.usesPreciseCollisionDetection = true;
        node.physicsBody?.categoryBitMask = CollisionCategoryBitmask.Player;
        node.physicsBody?.collisionBitMask = 0;
        node.physicsBody?.contactTestBitMask = CollisionCategoryBitmask.Platform | CollisionCategoryBitmask.Star;
        
        return node;
    }
    
    /**
    创建 star
    
    :returns: return star
    */
    private func createStarAtPosition(position:CGPoint, ofType type:StarType) -> SKNode
    {
        let pos = CGPoint(x: position.x * scaleRate, y: position.y);
        return StarNode.createStarAtPosition(pos, ofType: type);
    }
    
    //开始接触
    func didBeginContact(contact: SKPhysicsContact) {
        var updateHUD = false;
        
        let whichNode = contact.bodyA.node == self.player ? contact.bodyB.node : contact.bodyA.node;
        let other = whichNode as! GameObjectNode;
        
        updateHUD = other.collisionWithPlayer(player);
        
        if updateHUD
        {
            //do sth;
        }
    }
	
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        if player.physicsBody!.dynamic{ return; };
        
        tapToStartNode.removeFromParent();
        
        //物理模型类型改成动态的
        player.physicsBody?.dynamic = true;
        
        //给一个矢量的推力
        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20));
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
