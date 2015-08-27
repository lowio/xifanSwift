//
//  GameViewController.swift
//  CommonProject
//
//  Created by 173 on 15/8/27.
//  Copyright (c) 2015年 yeah. All rights reserved.
//

import UIKit
import SpriteKit


class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        var q = PriorityQueue<Int>(){$0.0 > $0.1}
        
        
        for i in 0...49
        {
            let temp = Int(arc4random() % 100);
            q.push(temp);
        }
        
        
        println(q)
        
        while(!q.empty)
        {
            println(q.pop());
        }
        
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
