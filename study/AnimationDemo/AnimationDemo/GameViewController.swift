//
//  GameViewController.swift
//  AnimationDemo
//
//  Created by 叶贤辉 on 15/3/20.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let v = self.view as! SKView
        v.showsFPS = true
        v.showsNodeCount = true
        v.ignoresSiblingOrder = true
        let s = GameScene(size:v.bounds.size)
        s.scaleMode = SKSceneScaleMode.ResizeFill
        v.presentScene(s)
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
