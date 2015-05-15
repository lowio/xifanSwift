//
//  GameViewController.swift
//  SpriteKitProgrammingGuide
//
//  Created by 173 on 15/5/15.
//  Copyright (c) 2015年 173. All rights reserved.
//

import UIKit
import SpriteKit

/**
*  game controller
*/
class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad();
        
        setupRootView();
    }
    
    
    
    /**
    设置根view
    */
    private func setupRootView()
    {
        let skView = self.view as! SKView;
        skView.showsDrawCount = true;
        skView.showsNodeCount = true;
        skView.showsFPS = true;
    }
    
    
    override func viewWillAppear(animated: Bool) {
        let scene = StartScene(size: self.view.bounds.size);
        (self.view as! SKView).presentScene(scene);
        
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
