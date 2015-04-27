//
//  GameViewController.swift
//  Threes!
//
//  Created by 叶贤辉 on 15/2/4.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import UIKit
import SpriteKit



class GameViewController: UIViewController, UIGestureRecognizerDelegate {

    //controller
    var controller:NodesController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initGame(view: self.view as! SKView)
    }
    
    //初始化游戏
    private func initGame(view v:SKView)
    {
        v.showsFPS = true
        v.showsNodeCount = true
        v.ignoresSiblingOrder = true
        
        controller = NodesController(view: v, columns: GameConfig.columns, rows: GameConfig.rows)
        controller!.start()
    }
    
    //swipe
    @IBAction func swipe(sender:UISwipeGestureRecognizer)
    {
        controller?.swipe(sender.direction)
    }
}
