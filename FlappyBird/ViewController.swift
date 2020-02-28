//
//  ViewController.swift
//  FlappyBird
//
//  Created by NAOKI II on 2020/02/26.
//  Copyright © 2020 NAOKI.II. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //SKViewに型を変換する
        let skView = self.view as! SKView
        
        //FPSを表示する
        skView.showsFPS = true
        
        //ノードの数を表示する
        skView.showsNodeCount = true
        
        //ビューと同じサイズシーンを作成する
        let scren = GameScene(size: skView.frame.size)
        
        //ビューにシーンを表示する
        skView.presentScene(scren)
        
        //ステータスバーを消す
        var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    }


}

 
