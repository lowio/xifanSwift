//
//  GameViewController.swift
//  XCrunch
//
//  Created by 叶贤辉 on 15/4/13.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    var scene:GameScene!;
    
    var level:Level!;

    override func viewDidLoad() {
        super.viewDidLoad()

        //configure the view
        let skView = self.view as! SKView;
        skView.multipleTouchEnabled = false;
        skView.showsFPS = true;
//        skView.showsDrawCount = true;
        skView.showsNodeCount = true;
        
        //create gamescene & configure it;
        scene = GameScene(size: skView.bounds.size);
        scene.scaleMode = .AspectFill;
        
        //present scene;
        skView.presentScene(scene);
        
        
        beginGame();
    }
    
    //开始游戏
    func beginGame()
    {
        level = Level(fileName: "Level_1");
        scene.level = level;
        createGame();
    }
    
    //创建游戏
    func createGame()
    {
        let nodes = level.createNodes();
        scene.swipeHandler = handSwipe;
        scene.initNodes(nodes);
        scene.addTiles();
    }
    
    private func handSwipe(swipe:Swap)
    {
        view.userInteractionEnabled = false;
        
        if level.isPossibleSwap(swipe)
        {
            level.validateSwipe(swipe);
            scene.validateAnimateSwipe(swipe){
                self.validateChianSet();
            }
        }
        else
        {
            scene.invalidateAnimateSwipe(swipe){
               self.view.userInteractionEnabled = true;
            }
        }
        
    }
    
    private func validateChianSet()
    {
        let set = level.getChianSet();
        if set.count == 0
        {
            self.level.detectPossibleSwapNodes();
            self.view.userInteractionEnabled = true;
            return ;
        }
        self.scene.removeChianNodes(set){
            let nodes = self.level.fallDownRemaining();
            self.scene.fallDownRemaining(nodes){
                let newNodes = self.level.fillTheNilSpace();
                self.scene.fillTheNilSpace(newNodes){
                    self.validateChianSet();
                }
            };
        }
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.AllButUpsideDown;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
