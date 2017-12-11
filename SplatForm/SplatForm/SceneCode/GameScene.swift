//
//  GameScene.swift
//  SplatForm
//  Manages core game logic and input management for SplatForm
//
//  Created by James McQuaid and Robert Bailey on 11/14/17.
//  Copyright © 2017 splat. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
  static let None: UInt32 = 0
  static let All: UInt32 = UInt32.max
  static let Ball: UInt32 = 0b1
  static let Platform: UInt32 = 0b10
}


class GameScene: SKScene, SKPhysicsContactDelegate {
  
  //MARK: - Level Management -
  var levelNum:Int = 1
  var numberOfLevels = 8
  var sceneManager:SceneManager = GameViewController()
  
  //MARK: - Button and Ball Management -
  var blueball: SKSpriteNode!
  var redball: SKSpriteNode!
  var yellowball: SKSpriteNode!
  var platforms: [SKSpriteNode] = []
  var cannonAngle:CGFloat = 0
  var touchCount:Int = 0
  var resetButton: SKSpriteNode!
  
  //MARK: - Color Management -
  let white = SKColor(red: 1, green: 1, blue: 1, alpha: 1)
  let blue = SKColor(red: 0, green: 0, blue: 1, alpha: 1)
  let red = SKColor(red: 1, green: 0, blue: 0, alpha: 1)
  let yellow = SKColor(red: 1, green: 1, blue: 0, alpha: 1)
  let green = SKColor(red: 0, green: 1, blue: 0, alpha: 1)
  let purple = SKColor(red: 0.75, green: 0, blue: 0.75, alpha: 1)
  let orange = SKColor(red: 1, green: 0.5, blue: 0, alpha: 1)
  let black = SKColor(red: 0, green: 0, blue: 0, alpha: 1)
  
  //MARK: - Ball Launching Management -
  var yellowLaunchBall: SKSpriteNode!
  var blueLaunchBall: SKSpriteNode!
  var redLaunchBall: SKSpriteNode!
  var ballToLaunch: SKSpriteNode!
  var ballLoaded:Bool = false
  var ballPrimed:Bool = false
  
  //MARK: - Scoring Management -
  var ballsUsed:Int = 0
  var scoreLabel:SKLabelNode?
  var colorToWin:SKColor!
  var correctPlatforms = 0
  
  //MARK: - Cannon Management -
  let cannonNode: Cannon = Cannon.init()
  var cannonBase: SKSpriteNode!
  var loadedBall: SKSpriteNode!
  
  //MARK: - Class Function to Load Levels -
  class func loadLevel(_ levelNum: Int, ballsUsed: Int, size: CGSize, scaleMode: SKSceneScaleMode, sceneManager:SceneManager) -> GameScene?{
    let scene = GameScene(fileNamed: "level\(levelNum)")!
    scene.levelNum = levelNum
    scene.ballsUsed = ballsUsed
    scene.size = size
    scene.scaleMode = scaleMode
    scene.sceneManager = sceneManager
    return scene
  }
  
  //MARK: - initialization -
  override func didMove(to view: SKView) {
    
    physicsWorld.contactDelegate = self
    
    run(SKAction.playSoundFileNamed("changeLevel.mp3", waitForCompletion: false))
    
    if(levelNum == 1){
      colorToWin = blue
    } else if(levelNum == 2) {
      colorToWin = yellow
    } else if(levelNum == 3){
      colorToWin = red
    } else if(levelNum == 4){
      colorToWin = purple
    } else if(levelNum == 5){
      colorToWin = orange
    } else if(levelNum == 6){
      colorToWin = red
    } else if(levelNum == 7){
      colorToWin = purple
    } else if(levelNum == 8){
      colorToWin = green
    }
    
    //Assigns variables to control for each level based off of reading in the scene
    for child in self.children {
      if child.name == "cannonBase"{
        cannonBase = child as? SKSpriteNode
        cannonNode.setBase(baseIn: cannonBase)
      }
      
      if child.name == "cannonBarrel"{
        let cannonBarrel = child as? SKSpriteNode
        cannonNode.setBarrel(barrelIn: cannonBarrel!)
      }
      
      if child.name == "score"{
        scoreLabel = child as? SKLabelNode
        scoreLabel?.text = "Balls Used: \(ballsUsed)"
      }
      if child.name == "resetButton"{
        resetButton = child as? SKSpriteNode
      }
      
      if child.name == "redball"{
        if let child = child as? SKSpriteNode {
          child.color = red
          child.physicsBody?.categoryBitMask = PhysicsCategory.Ball
          child.physicsBody?.contactTestBitMask = PhysicsCategory.Platform
          child.physicsBody?.collisionBitMask = PhysicsCategory.Platform
          redLaunchBall = child
        }
      }
      if child.name == "launchball"{
        if let child = child as? SKSpriteNode{
          child.physicsBody?.categoryBitMask = PhysicsCategory.Ball
          child.physicsBody?.contactTestBitMask = PhysicsCategory.Platform
          child.physicsBody?.collisionBitMask = PhysicsCategory.Platform
        }
      }
      if child.name == "yellowball" {
        if let child = child as? SKSpriteNode {
          child.color = yellow
          child.physicsBody?.categoryBitMask = PhysicsCategory.Ball
          child.physicsBody?.contactTestBitMask = PhysicsCategory.Platform
          child.physicsBody?.collisionBitMask = PhysicsCategory.Platform
          yellowLaunchBall = child
        }
      }
      if child.name == "blueball" {
        if let child = child as? SKSpriteNode {
          child.color = blue
          child.physicsBody?.categoryBitMask = PhysicsCategory.Ball
          child.physicsBody?.contactTestBitMask = PhysicsCategory.Platform
          child.physicsBody?.collisionBitMask = PhysicsCategory.Platform
          blueLaunchBall = child
        }
      }
      if child.name == "platform"{
        if let child = child as? SKSpriteNode {
          child.color = white
          child.physicsBody?.categoryBitMask = PhysicsCategory.Platform
          child.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
          child.physicsBody?.collisionBitMask = PhysicsCategory.Ball
          platforms.append(child)
        }
      }
      
      if child.name == "movingPlatform"{
        if let child = child as? SKSpriteNode {
          child.color = white
          child.physicsBody?.categoryBitMask = PhysicsCategory.Platform
          child.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
          child.physicsBody?.collisionBitMask = PhysicsCategory.Ball
          let moveDownAction = SKAction.move(to: CGPoint(x: child.position.x, y: child.position.y - 500), duration: 2)
          let moveUpAction = SKAction.move(to: CGPoint(x: child.position.x, y: child.position.y + 500), duration: 2)
          child.run(SKAction.repeatForever(SKAction.sequence([moveDownAction, moveUpAction])))
          platforms.append(child)
        }
      }
    }
  }
  
  //MARK: - Collision Management -
  func didBegin(_ contact: SKPhysicsContact) {
    var firstBody: SKPhysicsBody
    var secondBody: SKPhysicsBody
    
    if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
      firstBody = contact.bodyA
      secondBody = contact.bodyB
    } else {
      firstBody = contact.bodyB
      secondBody = contact.bodyA
    }
    
    if ((firstBody.categoryBitMask & PhysicsCategory.Ball != 0) && (secondBody.categoryBitMask & PhysicsCategory.Platform != 0)) {
      if let ball = firstBody.node as? SKSpriteNode, let platform = secondBody.node as? SKSpriteNode {
        ballCollision(ball: ball, platform: platform)
      }
    }
    
  }
  
  //MARK: - Ball Collision -
  func ballCollision(ball: SKSpriteNode, platform: SKSpriteNode) {
    
    //if blueball
    if(ball.color == blue){
      if(platform.color == white){
        platform.color = blue
      } else if (platform.color == red){
        platform.color = purple
      } else if (platform.color == yellow){
        platform.color = green
      } else if (platform.color == orange){
        platform.color = black
      }
    }
    
    //if redball
    if(ball.color == red){
      if(platform.color == white){
        platform.color = red
      } else if (platform.color == blue){
        platform.color = purple
      } else if (platform.color == yellow){
        platform.color = orange
      } else if (platform.color == green){
        platform.color = black
      }
    }
    
    //if yellowball
    if(ball.color == yellow){
      if(platform.color == white){
        platform.color = yellow
      } else if (platform.color == blue){
        platform.color = green
      } else if (platform.color == red){
        platform.color = orange
      } else if (platform.color == purple){
        platform.color = black
      }
    }
    
    displayEmitter(platform: platform)
    
    
    for platform in self.platforms{
      if(platform.color == colorToWin){
        correctPlatforms += 1
        print("\(correctPlatforms)")
        if(correctPlatforms == self.platforms.count){
          if(levelNum >= numberOfLevels){
            sceneManager.loadEndScene(ballsUsed: ballsUsed)
          } else {
            sceneManager.loadGameScene(levelNum: levelNum + 1, ballsUsed: ballsUsed)
          }
        }
      }
    }
    correctPlatforms = 0;
  }
  
  //MARK: - Display Emitter -
  func displayEmitter(platform: SKSpriteNode){
    
    var splatEmitter:SKEmitterNode?
    
    if(platform.color == self.blue){
      splatEmitter = SKEmitterNode(fileNamed: "BlueSplat")!
      splatEmitter!.position = platform.position
      splatEmitter!.zRotation = platform.zRotation + CGFloat(Double.pi)/2
      run(SKAction.playSoundFileNamed("splating.mp3", waitForCompletion: false))
    }
    if(platform.color == self.red){
      splatEmitter = SKEmitterNode(fileNamed: "RedSplat")!
      splatEmitter!.position = platform.position
      splatEmitter!.zRotation = platform.zRotation + CGFloat(Double.pi)/2
      run(SKAction.playSoundFileNamed("splating.mp3", waitForCompletion: false))
    }
    if(platform.color == self.yellow){
      splatEmitter = SKEmitterNode(fileNamed: "YellowSplat")!
      splatEmitter!.position = platform.position
      splatEmitter!.zRotation = platform.zRotation + CGFloat(Double.pi)/2
      run(SKAction.playSoundFileNamed("splating.mp3", waitForCompletion: false))
    }
    if(platform.color == self.purple){
      splatEmitter = SKEmitterNode(fileNamed: "PurpleSplat")!
      splatEmitter!.position = platform.position
      splatEmitter!.zRotation = platform.zRotation + CGFloat(Double.pi)/2
      run(SKAction.playSoundFileNamed("splating.mp3", waitForCompletion: false))
    }
    if(platform.color == self.green){
      splatEmitter = SKEmitterNode(fileNamed: "GreenSplat")!
      splatEmitter!.position = platform.position
      splatEmitter!.zRotation = platform.zRotation + CGFloat(Double.pi)/2
      run(SKAction.playSoundFileNamed("splating.mp3", waitForCompletion: false))
    }
    if(platform.color == self.orange){
      splatEmitter = SKEmitterNode(fileNamed: "OrangeSplat")!
      splatEmitter!.position = platform.position
      splatEmitter!.zRotation = platform.zRotation + CGFloat(Double.pi)/2
      run(SKAction.playSoundFileNamed("splating.mp3", waitForCompletion: false))
    }
    if(platform.color == self.black){
      splatEmitter = SKEmitterNode(fileNamed: "BlackSplat")!
      splatEmitter!.position = platform.position
      splatEmitter!.zRotation = platform.zRotation + CGFloat(Double.pi)/2
    }
    
    self.addChild(splatEmitter!)
    let lifeSpan = SKAction.scale(by: 2.0, duration: 1)
    let die = SKAction.removeFromParent()
    
    splatEmitter?.run(SKAction.sequence([lifeSpan, die]))
    
  }
  
  //MARK: - Touch Management -
  func touchDown(atPoint pos : CGPoint) {
  }
  
  //Processes touch movement to adjust cannon angle. It calls cannonNode.calcAngle to have the cannon point at the player's finger
  func touchMoved(toPoint pos : CGPoint) {
    let touch = pos
    cannonNode.calcAngle(touchX: touch.x, touchY: touch.y)
    print("fingers crossed")
  }
  
  //On release, the ball fires if loaded into the cannon
  func touchUp(atPoint pos : CGPoint) {
    
    //If the cannon is loaded properly (to avoid errors on non-level screens
    if cannonNode.barrel != nil {
      //And if the cannon is not loaded
      if(!cannonNode.loaded){
        //Prime the cannon, and load it
        if(cannonNode.primed){
          cannonNode.loadCannon()
          cannonNode.unprimeCannon()
        }
      }
      //If the cannon is loaded
      else{
        //Move the ball to fire to the cannon's base, and shoot it at the cannon's angle
        ballToLaunch.position = (cannonNode.base?.position)!
        cannonNode.fireCannon()
        run(SKAction.playSoundFileNamed("cannonFiring.mp3", waitForCompletion: false))
        
        ballToLaunch.physicsBody?.linearDamping = 0.0
        ballToLaunch.physicsBody?.velocity = CGVector(dx: cannonNode.launchX, dy: cannonNode.launchY)
        //Increase the count
        ballsUsed += 1
        scoreLabel?.text = "Balls Used: \(ballsUsed)"
        touchCount = touchCount + 1
        //Deactivate the cannon, and reset the loadedball
        cannonNode.unloadCannon()
        loadedBall.removeFromParent()
      }
    }
    
  }
  
 
  //MARK: - Touch Start -
  //Checks if any specific sprite nodes are touched, and processes them accordingly
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

    let touch = touches.first as UITouch!
    let targetNode = atPoint((touch?.location(in: self))!) as! SKNode
    //Reset
    if(targetNode == resetButton){
      reset()
    }
    
    //Load specific colors
    //Moves the coorect ball to the cannon, and calls the ready method
    if(targetNode.name == "redInv"){
      loadedBall = self.childNode(withName: "redInv")?.copy() as! SKSpriteNode
      self.addChild(loadedBall)
      readyRed()
    }
    if(targetNode.name == "blueInv"){
      loadedBall = self.childNode(withName: "blueInv")?.copy() as! SKSpriteNode
      self.addChild(loadedBall)
      readyBlue()
    }
    if(targetNode.name == "yellowInv"){
      loadedBall = self.childNode(withName: "yellowInv")?.copy() as! SKSpriteNode
      self.addChild(loadedBall)
      readyYellow()
    }
    for t in touches { self.touchDown(atPoint: t.location(in: self)) }
  }
  
  //MARK: - Reset -
  //Gives a more readable reset method than the sceneManager default
  func reset(){
    sceneManager.reloadGameScene(levelNum: levelNum, ballsUsed: ballsUsed)
  }
  
  //MARK: - Ready Methods -
  //Sets the ballToLaunch properties to that of the clicked item
  //Primes the cannon so it isn't instantly fired
  //And moves the ball to the correct spot
  func readyBlue(){
    ballToLaunch = blueLaunchBall
    cannonNode.primeCannon()
    loadedBall.position = CGPoint(x: -794, y: -670)
  }
  
  func readyRed(){
    ballToLaunch = redLaunchBall
    cannonNode.primeCannon()
    loadedBall.position = CGPoint(x: -794, y: -670)
  }
  
  func readyYellow(){
    ballToLaunch = yellowLaunchBall
    cannonNode.primeCannon()
    loadedBall.position = CGPoint(x: -794, y: -670)
  }
  //MARK: - Generic Touch Handlers -
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    for t in touches { self.touchUp(atPoint: t.location(in: self)) }
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    for t in touches { self.touchUp(atPoint: t.location(in: self)) }
  }
  
  //MARK: - Generic Update Handlers -
  override func update(_ currentTime: TimeInterval) {
  }
}
