//
//  ViewController.swift
//  CALayerDemo
//
//  Created by 叶贤辉 on 15/3/27.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.view.addSubview(SimpleView());
        self.view.addSubview(GradientDemo());
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func onTap(sender: UITapGestureRecognizer) {
    }

    @IBAction func onPinch(sender: UIPinchGestureRecognizer) {
    }
}

