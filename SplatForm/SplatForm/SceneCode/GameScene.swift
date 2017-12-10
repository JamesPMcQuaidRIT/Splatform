//
//  GameScene.swift
//  SplatForm
//
//  Created by student on 11/14/17.
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
  var cannonNode: Cannon = Cannon.init()


  var cannon : SKSpriteNode!
  private var label : SKLabelNode?
  private var spinnyNode : SKShapeNode?
  
  var levelNum:Int = 1
  var numberOfLevels = 5
  var sceneManager:SceneManager = GameViewController()
    
  var blueball: SKSpriteNode!
  var redball: SKSpriteNode!
  var yellowball: SKSpriteNode!
  var platforms: [SKSpriteNode] = []
  var inventoryBalls: [SKSpriteNode] = []
  var cannonAngle:CGFloat = 0
  var touchCount:Int = 0
  var resetButton: SKSpriteNode!
  
  var white = SKColor(red: 1, green: 1, blue: 1, alpha: 1)
  var blue = SKColor(red: 0, green: 0, blue: 1, alpha: 1)
  var red = SKColor(red: 1, green: 0, blue: 0, alpha: 1)
  var yellow = SKColor(red: 1, green: 1, blue: 0, alpha: 1)
  var green = SKColor(red: 0, green: 1, blue: 0, alpha: 1)
  var purple = SKColor(red: 0.75, green: 0, blue: 0.75, alpha: 1)
  var orange = SKColor(red: 1, green: 0.5, blue: 0, alpha: 1)
  var black = SKColor(red: 0, green: 0, blue: 0, alpha: 1)
  
  var yellowLaunchBall: SKSpriteNode!
  var blueLaunchBall: SKSpriteNode!
  var redLaunchBall: SKSpriteNode!
  
  var ballToLaunch: SKSpriteNode!
  var ballLoaded:Bool = false
  var ballPrimed:Bool = false
  var ballsUsed:Int = 0
  var scoreLabel:SKLabelNode?
  var colorToWin:SKColor!
  var correctPlatforms = 0
  var cannonBase: SKSpriteNode!
  var loadedBall: SKSpriteNode!
  
  var cannonForce:CGFloat = 1250
  
  class func loadLevel(_ levelNum: Int, ballsUsed: Int, size: CGSize, scaleMode: SKSceneScaleMode, sceneManager:SceneManager) -> GameScene?{
    let scene = GameScene(fileNamed: "level\(levelNum)")!
    scene.levelNum = levelNum
    scene.ballsUsed = ballsUsed
    scene.size = size
    scene.scaleMode = scaleMode
    scene.sceneManager = sceneManager
    return scene
  }
  
    override func didMove(to view: SKView) {
        
      physicsWorld.contactDelegate = self
      
      if(levelNum == 1){
        colorToWin = blue
      } else if(levelNum == 2) {
        colorToWin = purple
      } else if(levelNum == 3){
        colorToWin = purple
      } else if(levelNum == 4){
        colorToWin = red
      } else if(levelNum == 5){
        colorToWin = purple
      }
      
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
           // child.isUserInteractionEnabled = false
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
            //var blueTexture = SKTexture(image: "BlueBall.png")
              if(child.color == blue){
             //   child.color = yellow
              }
              child.physicsBody?.categoryBitMask = PhysicsCategory.Ball
              child.physicsBody?.contactTestBitMask = PhysicsCategory.Platform
              child.physicsBody?.collisionBitMask = PhysicsCategory.Platform
              inventoryBalls.append(child)
              
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
              
              let moveDownAction = SKAction.move(to: CGPoint(x: -150, y: -250), duration: 2)
              let moveUpAction = SKAction.move(to: CGPoint(x: -150, y: 450), duration: 2)
              
              child.run(SKAction.repeatForever(SKAction.sequence([moveDownAction, moveUpAction])))
              
              platforms.append(child)
            }
          }
      }
    }
    
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

  
  func displayEmitter(platform: SKSpriteNode){
    var splatEmitter:SKEmitterNode?
    
    if(platform.color == self.blue){
      splatEmitter = SKEmitterNode(fileNamed: "BlueSplat")!
      splatEmitter!.position = platform.position
      splatEmitter!.zRotation = platform.zRotation + CGFloat(Double.pi)/2
    }
    if(platform.color == self.red){
      splatEmitter = SKEmitterNode(fileNamed: "RedSplat")!
      splatEmitter!.position = platform.position
      splatEmitter!.zRotation = platform.zRotation + CGFloat(Double.pi)/2
    }
    if(platform.color == self.yellow){
      splatEmitter = SKEmitterNode(fileNamed: "YellowSplat")!
      splatEmitter!.position = platform.position
      splatEmitter!.zRotation = platform.zRotation + CGFloat(Double.pi)/2
    }
    if(platform.color == self.purple){
      splatEmitter = SKEmitterNode(fileNamed: "PurpleSplat")!
      splatEmitter!.position = platform.position
      splatEmitter!.zRotation = platform.zRotation + CGFloat(Double.pi)/2
    }
    if(platform.color == self.green){
      splatEmitter = SKEmitterNode(fileNamed: "GreenSplat")!
      splatEmitter!.position = platform.position
      splatEmitter!.zRotation = platform.zRotation + CGFloat(Double.pi)/2
    }
    if(platform.color == self.orange){
      splatEmitter = SKEmitterNode(fileNamed: "OrangeSplat")!
      splatEmitter!.position = platform.position
      splatEmitter!.zRotation = platform.zRotation + CGFloat(Double.pi)/2
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
    
    
    func touchDown(atPoint pos : CGPoint) {
      //  if let n = self.spinnyNode?.copy() as! SKShapeNode? {
      //     n.position = pos
       //     n.strokeColor = SKColor.green
      //      self.addChild(n)
      //  }
      

      //print(cannon)
    }
    
  func touchMoved(toPoint pos : CGPoint) {
    //  if let n = self.spinnyNode?.copy() as! SKShapeNode? {
    //      n.position = pos
    //      n.strokeColor = SKColor.blue
    //      self.addChild(n)
    //  }
    let touch = pos
    /*
     if let cannon = childNode(withName: "cannonBarrel") as? SKSpriteNode{
     print(cannon)
     let dX = cannon.position.x - touch.x
     let dY = cannon.position.y - touch.y
     let angle = atan2(dY, dX)
     cannon.zRotation = angle + (.pi / 180)
     cannonAngle = angle + (.pi / 180);
     }*/
    cannonNode.calcAngle(touchX: touch.x, touchY: touch.y)
    print("fingers crossed")
  }

    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
      let touch = pos
     // var newBall = childNode(withName: "blueball") as! SKSpriteNode
 
      if cannonNode.barrel != nil {
        if(!cannonNode.loaded){
          if(cannonNode.primed){
            cannonNode.loadCannon()
            cannonNode.unprimeCannon()
          }
        }
        else{
          ballToLaunch.position = (cannonNode.base?.position)!
          cannonNode.fireCannon()
          ballToLaunch.physicsBody?.linearDamping = 0.0
          ballToLaunch.physicsBody?.velocity = CGVector(dx: cannonNode.launchX, dy: cannonNode.launchY)
          ballsUsed += 1
          scoreLabel?.text = "Balls Used: \(ballsUsed)"
          
          touchCount = touchCount + 1
          cannonNode.unloadCannon()
          //ballLoaded = false;
          loadedBall.removeFromParent()
        }
      }

    }
  
  func reset(){
    //print(self.name)
    //let currScene:SKScene = SKScene(fileNamed: "level\(levelNum)")!
      //removeAllActions()
      //removeAllChildren()
    
      //let transition = SKTransition.fade(withDuration: 1) // create type of transition (you can check in documentation for more transtions)
      //currScene.scaleMode = SKSceneScaleMode.fill
      sceneManager.reloadGameScene(levelNum: levelNum, ballsUsed: ballsUsed)
    }
  
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        let touch = touches.first as UITouch!
        let touchLocation = touch?.location(in: self)
        let targetNode = atPoint((touch?.location(in: self))!) as! SKNode
        if(targetNode == resetButton){
          reset()
        }
        if(targetNode.name == "redInv"){
          print("red clicked")
          loadedBall = self.childNode(withName: "redInv")?.copy() as! SKSpriteNode
          self.addChild(loadedBall)
          readyRed()
        }
      if(targetNode.name == "blueInv"){
        print("blue clicked")
        loadedBall = self.childNode(withName: "blueInv")?.copy() as! SKSpriteNode
        self.addChild(loadedBall)
        readyBlue()
      }
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
  func readyBlue(){
    ballToLaunch = blueLaunchBall
    //ballPrimed = true;
    cannonNode.primeCannon()
    print(ballToLaunch)
    
    loadedBall.position = CGPoint(x: -794, y: -670)
    print(loadedBall)
    //ballToLaunch.position = cannonBase.position
  }
  
  func readyRed(){
    ballToLaunch = redLaunchBall
    //ballPrimed = true;
    cannonNode.primeCannon()
    print(ballToLaunch)
    loadedBall.position = CGPoint(x: -794, y: -670)
    
  }

  func readyYellow(){}
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
