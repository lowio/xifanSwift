//
//  GameViewController.swift
//  SwiftTris
//
//  Created by 叶贤辉 on 15/1/28.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController ,UIGestureRecognizerDelegate, SwiftTrisDelegate{

    var scene:GameScene!
    
    var smanager:SwiftTrisManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
        
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = SKSceneScaleMode.AspectFill
        scene.tick = updateByTick
        
        smanager = SwiftTrisManager(delegate:self)
        smanager.next()
        scene.nodeLayer.updateForm(smanager.fallingForm)
        scene.nodeLayer.updateForm(smanager.previewForm)
        skView.presentScene(scene)
        
        scene.tickStart()
    }
    
    
    func updateByTick()
    {
        smanager.autoFall()
        scene.nodeLayer.updateForm(smanager.fallingForm)
    }
    
    @IBAction func didTap(sender: UITapGestureRecognizer) {
        smanager.fallClockwise()
    }
    
    @IBAction func didSwipe(sender: UISwipeGestureRecognizer) {
        smanager.fallBottom()
    }

    @IBAction func swipeRight(sender: UISwipeGestureRecognizer) {
        smanager.fallRight()
    }

    @IBAction func swipLeft(sender: UISwipeGestureRecognizer) {
        smanager.fallLeft()
    }
    
    func next(manager: SwiftTrisManager) {
        if manager.fallingForm != nil
        {
            scene.nodeLayer.updateForm(manager.fallingForm)
        }
        manager.next()
        scene.nodeLayer.updateForm(manager.previewForm)
    }
    
    func gameOver(manager: SwiftTrisManager) {
        scene.tickStop()
    }

    func fall(manager: SwiftTrisManager) {
        scene.nodeLayer.updateForm(manager.fallingForm)
    }


    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
