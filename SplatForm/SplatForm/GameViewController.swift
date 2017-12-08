//
//  GameViewController.swift
//  SplatForm
//
//  Created by student on 11/14/17.
//  Copyright © 2017 splat. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController, SceneManager {

    var gameScene: GameScene?
    var skView:SKView!
    let screenSize = CGSize(width: 2048, height: 1536)
    let scaleMode = SKSceneScaleMode.aspectFill
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            //if let scene = SKScene(fileNamed: "level1") {
                // Set the scale mode to scale to fit the window
            //    scene.scaleMode = .aspectFill
                
                // Present the scene
            //    view.presentScene(scene)
            //}
            skView = self.view as! SKView
            loadHomeScene();
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    func loadHomeScene(){
        let scene = HomeScene.loadLevel(size: screenSize, scaleMode: scaleMode, sceneManager: self)
        let reveal = SKTransition.fade(withDuration: 1)
        
        skView.presentScene(scene!, transition: reveal)
    }
    
    func loadGameScene(levelNum: Int, ballsUsed: Int){
        gameScene = GameScene.loadLevel(levelNum, ballsUsed: ballsUsed, size: screenSize, scaleMode: scaleMode, sceneManager: self)
        
        let reveal = SKTransition.doorsOpenHorizontal(withDuration: 1)
        
        skView.presentScene(gameScene!, transition: reveal)
    }
    
    func reloadGameScene(levelNum: Int, ballsUsed: Int){
        gameScene = GameScene.loadLevel(levelNum, ballsUsed: ballsUsed, size: screenSize, scaleMode: scaleMode, sceneManager: self)
        
        let reveal = SKTransition.fade(withDuration: 1)
        
        skView.presentScene(gameScene!, transition: reveal)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
