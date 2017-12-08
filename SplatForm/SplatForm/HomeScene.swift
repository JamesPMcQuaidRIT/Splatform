//
//  HomeScene.swift
//  SplatForm
//
//  Created by student on 12/8/17.
//  Copyright © 2017 splat. All rights reserved.
//

import SpriteKit
import GameplayKit

class HomeScene: SKScene{

    var sceneManager:SceneManager = GameViewController()
    
    class func loadLevel(size: CGSize, scaleMode: SKSceneScaleMode, sceneManager:SceneManager) -> HomeScene?{
        let scene = HomeScene(fileNamed: "homeScene")!
        scene.size = size
        scene.scaleMode = scaleMode
        scene.sceneManager = sceneManager
        return scene
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        sceneManager.loadGameScene(levelNum: 1, ballsUsed: 0)
    }
}
