//
//  GameViewController.swift
//  JSONParser
//
//  Created by 叶贤辉 on 15/3/20.
//  Copyright (c) 2015年 叶贤辉. All rights reserved.
//

import UIKit
import SpriteKit



class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad();
        DataManager.getTopAppsDataFromFileWithSuccess(){
            (data) -> Void in
            self.getDataSuccess(jsData: data)
        };
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //获取数据成功
    private func getDataSuccess(jsData jsd : NSData)
    {
        let jsonParser = JSONParser(data: jsd);
//        let d = jsonParser["feed"]["author"]["uri"]["label"] as JSONParser
        let d = jsonParser["feed"]["author"] as JSONParser
        let v = d.stringValue
        println(d)
        println(v)
        
    }
}
