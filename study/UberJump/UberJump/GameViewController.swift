//
//  GameViewController.swift
//  UberJump
//
//  Created by 叶贤辉 on 15/4/21.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    //level
    var level:Level!;

    override func viewDidLoad() {
        super.viewDidLoad()

        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        
        let scene = GameScene(size:skView.bounds.size);
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
        
        skView.presentScene(scene);
        
        
        
        level = Level(configFileName: "Level01");
        
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
