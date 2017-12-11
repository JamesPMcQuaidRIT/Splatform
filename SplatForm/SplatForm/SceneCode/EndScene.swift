//
//  EndScene.swift
//  SplatForm
//
//  Created by James McQuaid on 12/9/17.
//  Copyright © 2017 splat. All rights reserved.
//

import SpriteKit
import GameplayKit

class EndScene: SKScene{
  
  //MARK: - Level Management -
  var sceneManager:SceneManager = GameViewController()
  var ballsUsed:Int = 0
  var finalScoreLabel:SKLabelNode?
  var bestScoreLabel:SKLabelNode?
  
  //MARK: - Loading Management -
  class func loadLevel(ballsUsed:Int, size: CGSize, scaleMode: SKSceneScaleMode, sceneManager:SceneManager) -> EndScene?{
    let scene = EndScene(fileNamed: "endScene")!
    scene.ballsUsed = ballsUsed
    scene.size = size
    scene.scaleMode = scaleMode
    scene.sceneManager = sceneManager
    return scene
  }
  
  //MARK: - Initilization  -
  override func didMove(to view: SKView) {
    if(ballsUsed < AppData.sharedData.lowestBallsUsed || AppData.sharedData.lowestBallsUsed == 0){
      AppData.sharedData.lowestBallsUsed = ballsUsed
    }
    
    for child in children{
      if(child.name == "finalScore"){
        print(ballsUsed)
        finalScoreLabel = child as? SKLabelNode
        finalScoreLabel?.text = "You Cleared the Game Using \(ballsUsed) Balls"
      }
      if(child.name == "bestScore"){
        bestScoreLabel = child as? SKLabelNode
        bestScoreLabel?.text = "The Lowest Number of Balls Used is \(AppData.sharedData.lowestBallsUsed)"
      }
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    sceneManager.loadHomeScene()
  }
}
