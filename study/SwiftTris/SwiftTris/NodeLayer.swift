//
//  NodeLayer.swift
//  SwiftTris
//
//  Created by 叶贤辉 on 15/1/30.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import Foundation
import SpriteKit



class NodeLayer: SKNode{
    let maxCloumn = 10
    let maxRow = 20
    

    
    //纹理缓存
    var textureCache = Dictionary<String, SKTexture>()
    
    
    override init() {
        super.init()
        creatBoard()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //创建board
    func creatBoard()
    {
        let bd = SKSpriteNode(texture: SKTexture(imageNamed: "gameboard"))
        bd.anchorPoint = CGPoint(x: 0, y: 1)
        addChild(bd)
    }
    
    
    let formSize:CGFloat = 20.0
    //获取position
    func getPosition(c:Int, r:Int) -> CGPoint
    {
        let x = CGFloat(c) * formSize
        let y = CGFloat(r) * formSize * CGFloat(-1.0)
        return CGPoint(x: x, y: y)
    }
    
    //更新form
    func updateForm(form:NodeForm!)
    {
        for n in form.nodeList
        {
            var d:SKSpriteNode? = n.display
            if d == nil && !n.createDisplay
            {
                n.createDisplay = true
                var t = textureCache[n.color.colorName]
                if t == nil
                {
                    t = SKTexture(imageNamed: n.color.colorName)
                    textureCache[n.color.colorName] = t
                }
                d = SKSpriteNode(texture: t)
                d?.anchorPoint = CGPoint(x: 0, y: 1)
                addChild(d!)
                n.display = d
            }
            
            d?.position = getPosition(n.column, r: n.row)
        }
    }
    
    
}