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
    var cannon : SKSpriteNode!
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    var blueball: SKSpriteNode!
    var redball: SKSpriteNode!
    var yellowball: SKSpriteNode!
    var platforms: [SKSpriteNode] = []
    
    var white = SKColor(red: 1, green: 1, blue: 1, alpha: 1)
    var blue = SKColor(red: 0, green: 0, blue: 1, alpha: 1)
    var red = SKColor(red: 1, green: 0, blue: 0, alpha: 1)
    var yellow = SKColor(red: 1, green: 1, blue: 0, alpha: 1)
    var green = SKColor(red: 0, green: 1, blue: 0, alpha: 1)
    var purple = SKColor(red: 0.75, green: 0, blue: 0.75, alpha: 1)
    var orange = SKColor(red: 1, green: 0.5, blue: 0, alpha: 1)
    var black = SKColor(red: 0, green: 0, blue: 0, alpha: 1)
    
    
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        
        blueball = childNode(withName: "blueball") as! SKSpriteNode
        blueball.color = blue
        blueball.physicsBody?.categoryBitMask = PhysicsCategory.Ball
        blueball.physicsBody?.contactTestBitMask = PhysicsCategory.Platform
        blueball.physicsBody?.collisionBitMask = PhysicsCategory.Platform
        
        redball = childNode(withName: "redball") as! SKSpriteNode
        redball.color = red
        redball.physicsBody?.categoryBitMask = PhysicsCategory.Ball
        redball.physicsBody?.contactTestBitMask = PhysicsCategory.Platform
        redball.physicsBody?.collisionBitMask = PhysicsCategory.Platform
        
        yellowball = childNode(withName: "yellowball") as! SKSpriteNode
        yellowball.color = yellow
        yellowball.physicsBody?.categoryBitMask = PhysicsCategory.Ball
        yellowball.physicsBody?.contactTestBitMask = PhysicsCategory.Platform
        yellowball.physicsBody?.collisionBitMask = PhysicsCategory.Platform
        
        for child in self.children {
            if child.name == "platform" {
                if let child = child as? SKSpriteNode {
                    child.color = white
                    child.physicsBody?.categoryBitMask = PhysicsCategory.Platform
                    child.physicsBody?.contactTestBitMask = PhysicsCategory.Ball
                    child.physicsBody?.collisionBitMask = PhysicsCategory.Ball
                    platforms.append(child)
                }
            }
        }
        
        
        
        /*// Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }*/
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
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
      let cannon : SKSpriteNode! = childNode(withName: "cannonBarrel") as! SKSpriteNode

      print(cannon)
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
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
