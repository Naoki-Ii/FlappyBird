//
//  GameScene.swift
//  FlappyBird
//
//  Created by NAOKI II on 2020/02/27.
//  Copyright © 2020 NAOKI.II. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    var scrollNode:SKNode!
    var wallNode:SKNode!
    var bird:SKSpriteNode!
    
    //衝突判定カテゴリー
    let birdCategory: UInt32 = 1 << 0
    let groundCategory: UInt32 = 1 << 1
    let wallCategory: UInt32 = 1 << 2
    let scoreCategory: UInt32 = 1 << 3

    //スコア用
    var score = 0
    //SkView上にシーンが表示された時に呼ばれるメソッド
    override func didMove(to view: SKView) {
        
        //重力を設定
        physicsWorld.gravity = CGVector(dx: 0, dy: -4)
        physicsWorld.contactDelegate = self
        
        //背景色を設定
        backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.75, alpha: 1)
        
        //スクロールするスプライトの親ノード
        scrollNode = SKNode()
        addChild(scrollNode)
        
        //壁用のノード
        wallNode = SKNode()
        scrollNode.addChild(wallNode)
        
        //各種スプライトを生成する処理をメソッドに分割
        setupGround()
        setupCloud()
        setupwall()
        setupBird()
    }
    
    //画面をタップした時に呼ばれるメソッド
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //鳥の速度をゼロにする
        bird.physicsBody?.velocity = CGVector.zero
        
        //鳥に縦方向の力を与える
        bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
    }
    
    //-------地面設置--------
    func setupGround() {
        
        //地面の画像読み込み
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = .nearest
        
        //必要な枚数を計算
        let needNumber = Int(self.frame.size.width / groundTexture.size().width) + 2
        
        //スクロールするアクションを作成
        //左方向に画像一枚分をスクロールさせるアクション
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 5)
        //元の位置に戻す悪アクション
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 5)
        
        //左にスクロール→元の位置→左にスクロールと無限に繰り返すアクション
        let repetScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround, resetGround]))
        
            //groundのスプライトを配置する
            for i in 0..<needNumber {
                let sprite = SKSpriteNode(texture: groundTexture)
                
                //テクスチャを指定してスプライトを作成する
                let groundSprite = SKSpriteNode(texture: groundTexture)
                
                //スプライトの表示する位置を指定する
                groundSprite.position = CGPoint(
                    x: groundTexture.size().width/2 + groundTexture.size().width * CGFloat(i),
                    y: groundTexture.size().height/2
                )
                
                //スプライトにアクションを設定する
                sprite.run(repetScrollGround)
                
                // スプライトに物理演算を設定する
                sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())

                // 衝突の時に動かないように設定する
                sprite.physicsBody?.isDynamic = false
                
                //シーンにスプライトを追加する
                addChild(groundSprite)
            }
        }
    
    //---------雲設置-----------
    func setupCloud() {
        
        //雲の画像を読み込む
        let cloudTexture = SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = .nearest
        
        //必要な枚数を計算
        let needCloudNumber = Int(self.frame.size.width / cloudTexture.size().width) + 2
        
        //スクロールするアクションを作成
        //左方向にに画像一枚分をスクロールさせるアクション
        let moveCloud = SKAction.moveBy(x: -cloudTexture.size().width, y: 0, duration: 20)
        
        //元に戻す
        let resetCloud = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0)
        
        //左にスクロール→元の位置→左にスクロールと無限に繰り返す
        let repeatScrolledCloud = SKAction.repeatForever(SKAction.sequence([moveCloud, resetCloud]))
        
            for i in 0..<needCloudNumber {
                let sprite  = SKSpriteNode(texture: cloudTexture)
                sprite.zPosition = -100 //一番後ろになるようにする
                //スプライトの表示をする位置を指定
                sprite.position = CGPoint(
                    x: cloudTexture.size().width/2 + cloudTexture.size().width * CGFloat(i),
                    y: self.size.height - cloudTexture.size().height/2
                )
                
                //スプライトにアニメーションを設置
                sprite.run(repeatScrolledCloud)
                
                //スプライトを追加する
                scrollNode.addChild(sprite)
            }
    }
    
    //--------壁設置------------
    func setupwall() {
        
        //壁の画像を読み込む
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = .linear //鮮明に表示
        
        //移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width)
        
        //画面外まで移動するアクションを作成
        let moveWall = SKAction.moveBy(x: -movingDistance, y: 0, duration: 4)
        
        //自信を取り除くアクションを作成
        let removeWall = SKAction.removeFromParent()
        
        //二つのアニメーションを順に実行するアクションを作成
        let wallAnimation = SKAction.sequence([moveWall, removeWall])
        
        //鳥の画像サイズを取得
        let birdSize = SKTexture(imageNamed: "bird_a").size()
        
        let slit_length = birdSize.height * 3
        
        //隙間位置の上下の揺れ幅を鳥の三倍のサイズとする
        let random_y_rang = birdSize.height * 3
        
        //下の壁のY軸下限位置（中央位置から下方向の最大揺れ幅で下の壁を表示する位置）を計算
        let groundSize = SKTexture(imageNamed: "ground").size()
        let center_y = groundSize.height + (self.frame.size.height - groundSize.height) / 2
        let under_wall_lowest_y = center_y - slit_length / 2 - wallTexture.size().height / 2 - random_y_rang / 2
        
        //壁を生成するアクションを作成
        let createWallAnimation = SKAction.run({
            
            //壁関連のノードを乗せるノードを作成
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.width + wallTexture.size().width / 2, y: 0)
            wall.zPosition = -50 //雲より手前地面より奥
            
            //0〜random_y_rangeまでのランダム値を生成
            let  random_y = CGFloat.random(in: 0..<random_y_rang)
            //Y軸の下限にランダムな値を足して、下の壁のY座標を決定下
            let under_wall_y = under_wall_lowest_y + random_y
            
            //下側の壁を作成
            let under = SKSpriteNode(texture: wallTexture)
            under.position = CGPoint(x: 0, y: under_wall_y)
            
            //スプライトに物理演算を設定する
            under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            under.physicsBody?.categoryBitMask = self.wallCategory
            
            //衝突の時に動かないようにする
            under.physicsBody?.isDynamic = false
            wall.addChild(under)
            
            //上側の壁を作成
            let  upper = SKSpriteNode(texture: wallTexture)
            upper.position = CGPoint(x: 0, y: under_wall_y + wallTexture.size().height + slit_length)
            
            //スプライトに物理演算を設定する
            upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            upper.physicsBody?.categoryBitMask = self.wallCategory
            
            //衝突の時に動かないようにする
            upper.physicsBody?.isDynamic = false
            wall.addChild(upper)
            
            //スコアUP用ノード
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: upper.size.width + birdSize.width / 2,
                                         y: self.frame.height / 2)
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width,
                                                                      height: self.frame.size.height))
            scoreNode.physicsBody?.isDynamic = false
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
            
            wall.addChild(scoreNode)
            
            wall.run(wallAnimation)
            
            self.wallNode.addChild(wall)
        })
        
        //  次の壁作成までの待ち時間のアクションを作成
        let waitAnimation = SKAction.wait(forDuration: 2)
        
        //壁を作成→時間待ちう→壁の作成を無限に繰り返すアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))
        
        wallNode.run(repeatForeverAnimation)
    }

    //-------鳥設置---------
    func setupBird() {
        //２種類の画像を読み込む
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = .linear
        let birdtextureB = SKTexture(imageNamed: "bird_b")
        birdtextureB.filteringMode = .linear
        
        //２種類のテクスチャを交互に変更するアニメーションを作成
        let texturesAnimation = SKAction.animate(with: [birdTextureA, birdtextureB] ,timePerFrame: 0.2)
        let flap = SKAction.repeatForever(texturesAnimation)
        
        //スプライト作成
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y: self.frame.size.height * 0.7)
        
        //物理演算を設定
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2)
        //アニメーション設定
        bird.run(flap)
        
        //スプライトを追加する
        addChild(bird)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}