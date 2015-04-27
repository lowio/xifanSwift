//
//  GameScene.swift
//  XCrunch
//
//  Created by 叶贤辉 on 15/4/13.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import SpriteKit


class GameScene: SKScene {
    
    override init(size: CGSize) {
        super.init(size: size);
        
        //configure anchorPoint
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5);
        
        //set background
        let bg = SKSpriteNode(imageNamed: "Background");
        self.addChild(bg);
        
        initMore();
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    //等级
    var level:Level!;
    
    let tileWidth:CGFloat = 32;
    let tileHeight:CGFloat = 36;
    
    //game layer
    let gameLayer = SKNode();
    
    //tile layer
    let tileLayer = SKNode();
    
    //node layer
    let nodeLayer = SKNode();
    
    //初始化
    private func initMore()
    {
        self.addChild(gameLayer);
        
        let layerPosition = CGPoint(x: -CGFloat(numColumns)/2 * tileWidth, y: -CGFloat(numRows)/2 * tileHeight);
        
        tileLayer.position = layerPosition;
        gameLayer.addChild(tileLayer);
        
        nodeLayer.position = layerPosition;
        gameLayer.addChild(nodeLayer);
    }
    
    //添加显示对象
    func initNodes(nodeDatas:Set<XNodeData>)
    {
        for node in nodeDatas
        {
            var sprite = SKSpriteNode(imageNamed: node.nodeType.spriteName);
            sprite.position = getPointAt(node.column, row: node.row);
            nodeLayer.addChild(sprite);
            node.sprite = sprite;
        }
    }
    
    //根据行列获取位置
    private func getPointAt(column:Int, row:Int) -> CGPoint
    {
        let x = CGFloat(column) * tileWidth + tileWidth/2;
        let y = CGFloat(row) * tileHeight + tileHeight/2;
        return CGPoint(x: x, y: y);
    }
    
    //添加tiles
    func addTiles()
    {
        for row in 0..<numRows
        {
            for column in 0..<numColumns
            {
                if level.getTileAt(column, row: row) == nil
                {
                    continue;
                }
                let ts = SKSpriteNode(imageNamed: "Tile");
                ts.position = getPointAt(column, row: row)
                tileLayer.addChild(ts);
            }
        }
    }
    
    //转换触摸坐标为行列
    private func convertTouchPoint(point:CGPoint) -> (success:Bool, column:Int, row:Int)
    {
        if point.x >= 0 && point.x < CGFloat(numColumns) * tileWidth
        && point.y >= 0 && point.y < CGFloat(numRows) * tileHeight
        {
            return (true , Int(point.x / tileWidth), Int(point.y / tileHeight));
        }
        return (false, 0, 0);
    }
    
    var swipeFromColumn:Int?;
    var swipeFromRow:Int?;
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch;
        
        var point = touch.locationInNode(nodeLayer);
        
        let (success, column, row) = convertTouchPoint(point);
        if success
        {
            if let node = level.getNodeAt(column, row: row)
            {
                swipeFromColumn = column;
                swipeFromRow = row;
                showLightSprite(node);
            }
        }
    }
    
    
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        if swipeFromColumn == nil
        {
            return;
        }
        
        let touch = touches.first as! UITouch;
        
        var point = touch.locationInNode(nodeLayer);
        
        let (success, column, row) = convertTouchPoint(point);
        
        if !success
        {
            return;
        }
        
        var hDelta:Int = 0
        var vDelta:Int = 0;
        
        if column < swipeFromColumn
        {
            hDelta = -1;
        }
        else if column > swipeFromColumn
        {
            hDelta = 1;
        }
        
        if row < swipeFromRow
        {
            vDelta = -1;
        }
        else if row > swipeFromRow
        {
            vDelta = 1;
        }
        
        if hDelta != 0 || vDelta != 0
        {
            trySwipeTo(hDelta, vDelta: vDelta);
            hideLightSprite();
            swipeFromColumn = nil;
        }
        
        
    }
    
    //移动到某
    private func trySwipeTo(hDelta:Int, vDelta:Int)
    {
        let toColumn = swipeFromColumn! + hDelta;
        let toRow = swipeFromRow! + vDelta;
        
        if toColumn < 0 || toColumn >= numColumns {return}
        if toRow < 0 || toRow >= numRows { return }
        
        if let toNode = level.getNodeAt(toColumn, row: toRow)
        {
            if let fromNode = level.getNodeAt(swipeFromColumn!, row: swipeFromRow!)
            {
                if let handler = swipeHandler
                {
                    handler(Swap(current: fromNode, target: toNode));
                }
            }
        }
    }
    
//    let swipeSound = SKAction.playSoundFileNamed("Chomp.wav", waitForCompletion: false);
//    let invalidSwipeSound = SKAction.playSoundFileNamed("Error.wav", waitForCompletion: false);
//    let matchSound = SKAction.playSoundFileNamed("Ka-Ching.wav", waitForCompletion: false);
//    let fallingCookieSound = SKAction.playSoundFileNamed("Scrape.wav", waitForCompletion: false);
//    let addCookieSound = SKAction.playSoundFileNamed("Drip.wav", waitForCompletion: false);
    
    
    //swipe移动动画
    func validateAnimateSwipe(swipe:Swap, complete:()->())
    {
        let from = swipe.current.sprite!;
        let to = swipe.target.sprite!;
        
        from.zPosition = 100;
        to.zPosition = 90;
        
        let d:NSTimeInterval = 0.3;
        
        let moveFrom = SKAction.moveTo(to.position, duration: d);
        moveFrom.timingMode = .EaseOut;
        from.runAction(moveFrom);
        
        let moveTo = SKAction.moveTo(from.position, duration: d);
        moveTo.timingMode = .EaseOut;
        to.runAction(moveTo);
        
        runAction(SKAction.waitForDuration(d), completion:complete);
        
//        runAction(swipeSound);
    }
    
    //swipe回滚
    func invalidateAnimateSwipe(swipe:Swap, complete:()->())
    {
        let from = swipe.current.sprite!;
        let to = swipe.target.sprite!;
        
        from.zPosition = 100;
        to.zPosition = 90;
        
        let d:NSTimeInterval = 0.2;
        
        let goAction = SKAction.moveTo(to.position, duration: d);
        goAction.timingMode = .EaseOut;
        let backAction = SKAction.moveTo(from.position, duration: d);
        backAction.timingMode = .EaseOut;
        
        from.runAction(SKAction.sequence([goAction, backAction]), completion: complete);
        to.runAction(SKAction.sequence([backAction, goAction]));
        
//        runAction(invalidSwipeSound);
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if lightSprite.parent != nil && swipeFromColumn != nil
        {
            hideLightSprite();
        }
        swipeFromColumn = nil;
        swipeFromRow = nil;
    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        touchesEnded(touches, withEvent: event);
    }
    
    //执行函数
    var swipeHandler:((Swap) -> ())?
    
    //高亮sprite
    var lightSprite = SKSpriteNode();
    
    //显示高亮
    func showLightSprite(node:XNodeData)
    {
        if lightSprite.parent != nil
        {
            lightSprite.removeFromParent();
        }
        
        if let sprite = node.sprite
        {
            let texture = SKTexture(imageNamed: node.nodeType.highLightedSpriteName);
            lightSprite.size = texture.size();
            lightSprite.runAction(SKAction.setTexture(texture));
            
            
            sprite.addChild(lightSprite);
            lightSprite.alpha = 1;
        }
    }
    
    //隐藏高亮
    func hideLightSprite()
    {
        lightSprite.runAction(SKAction.sequence([
            SKAction.fadeOutWithDuration(0.3),
            SKAction.removeFromParent()
            ]));
    }
    
    //移除显示对象
    func removeChianNodes(set:Set<Chian>, complete:()->())
    {
        for chian in set
        {
            for node in chian.nodes
            {
                if let sprite = node.sprite
                {
                    let actionKey = "removeActino";
                    if sprite.actionForKey(actionKey) != nil
                    {
                        continue;
                    }
                    
                    let scaleAction = SKAction.scaleTo(0.1, duration: 0.3);
                    scaleAction.timingMode = .EaseOut;
                    sprite.runAction(SKAction.sequence([scaleAction, SKAction.removeFromParent()]), withKey:actionKey);
                }
            }
        }
        
        //播放声音
        runAction(SKAction.waitForDuration(0.3), completion: complete);
    }
    
    //移除后生育项目 依此降落
    func fallDownRemaining(nodes:[[XNodeData]], complete:()->())
    {
        var longestDuration:NSTimeInterval = 0;
        
        for arr in nodes
        {
            for (index, node) in enumerate(arr)
            {
                let newpos = getPointAt(node.column, row: node.row);
                
                let delay = 0.05 + 0.15 * NSTimeInterval(index);
                
                let sprite = node.sprite!;
                
                let duration = NSTimeInterval((sprite.position.y - newpos.y )/tileHeight * 0.1);
                
                longestDuration = max(longestDuration, duration + delay);
                
                let moveAction = SKAction.moveTo(newpos, duration: duration);
                moveAction.timingMode = .EaseOut;
                
                let p = sprite.position;
//                sprite.runAction(SKAction.sequence([SKAction.waitForDuration(delay),
//                    SKAction.group([moveAction])]));//group中应该同时播放音效
                sprite.runAction(SKAction.sequence([SKAction.waitForDuration(delay),
                    SKAction.group([moveAction])])){
                }
            }
        }
        
        runAction(SKAction.waitForDuration(longestDuration), completion:complete);
    }
    
    //填充新的node
    func fillTheNilSpace(fillNodes:[[XNodeData]], complate:() -> ())
    {
        var longestDuration: NSTimeInterval = 0
        
        for array in fillNodes {
            let startRow = array[0].row + 1
            
            for (idx, node) in enumerate(array) {
                let sprite = SKSpriteNode(imageNamed: node.nodeType.spriteName)
                sprite.position = getPointAt(node.column, row: startRow);
                nodeLayer.addChild(sprite)
                node.sprite = sprite
                
                let delay = 0.1 + 0.2 * NSTimeInterval(array.count - idx - 1)
                
                let duration = NSTimeInterval(startRow - node.row) * 0.1
                longestDuration = max(longestDuration, duration + delay)
                
                let newPosition = getPointAt(node.column, row: node.row)
                let moveAction = SKAction.moveTo(newPosition, duration: duration)
                moveAction.timingMode = .EaseOut
                sprite.alpha = 0
                sprite.runAction(
                    SKAction.sequence([
                        SKAction.waitForDuration(delay),
                        SKAction.group([
                            SKAction.fadeInWithDuration(0.05),
                            moveAction])
                        ]))
            }
        }
        // 7
        runAction(SKAction.waitForDuration(longestDuration), completion: complate)
    }
}
