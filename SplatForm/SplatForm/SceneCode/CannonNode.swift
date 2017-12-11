//
//  Cannon.swift
//  SplatForm
//
//  Custom SKSpriteNode to manage cannon logic and readability
//  Manages firing and input management of the cannon SKSpriteNode
//
//  Created by Robert Bailey on 12/10/17.
//  Copyright © 2017 splat. All rights reserved.
//

import Foundation
import SpriteKit

class Cannon: SKSpriteNode{
  
  //MARK: - Components -
  var base:SKNode?
  var barrel:SKNode?
  var angle:CGFloat = 0
  var positionX:CGFloat = 0
  var positionY: CGFloat = 0
  
  //MARK: - Controllers -
  let radianConversion = CGFloat.pi/180
  var loaded:Bool = false
  var primed:Bool = false
  var force:CGFloat = 1250
  
  //MARK: - Values to pass -
  var launchX:CGFloat = 0
  var launchY:CGFloat = 0
  
  //MARK: - init -
  init() {
    self.angle = 0
  
    //Passes in generic super.init to check for really bad errors and fulfill role
    super.init(texture: .init(), color: .gray, size: CGSize.init())
  }
  
  //MARK: - Error init -
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  //MARK: - Setting Barrel -
  //Called from within GameScene to give Barrel a value
  func setBarrel(barrelIn: SKSpriteNode){
    self.barrel = barrelIn
    //Uses barrel position for ball launching
    self.positionX = barrelIn.position.x
    self.positionY = barrelIn.position.y
  }
  
  //MARK: - Setting Base -
  //Called within GameScene to give Base a value
  func setBase(baseIn: SKSpriteNode){
    self.base = baseIn
  }
  
  //MARK: - Calculate Error -
  //Called with a touch to update the cannon's angle in response to user input
  func calcAngle(touchX: CGFloat, touchY: CGFloat){
    let dX = self.positionX - touchX
    let dY = self.positionY - touchY
    let distAngle = atan2(dY,dX)
    self.barrel!.zRotation = angle + radianConversion
    self.angle = distAngle + radianConversion
  }
  
  //MARK: - Management methods -
  //These manage the phases of firing the cannon
  //Load and unload are related to loading the ball into the cannon
  //Prime and unprime are related to processing the first input
  //This allows the single touch to be processed with multiple results
  func loadCannon(){
    self.loaded = true
  }
  func unloadCannon(){
    self.loaded = false
  }
  func primeCannon(){
    self.primed = true
  }
  func unprimeCannon(){
    self.primed = false
  }
  
  //MARK: - Fire Cannon -
  //Resets the control values and sets the launch operations to be assigned to the paint ball
  func fireCannon(){
    self.loaded = false
    self.primed = false
    
    //Checks if the cannon is pointed wrong why at load in, and resets it if needed
    if(self.angle != 0){
      self.launchX =  self.force * cos(self.angle) * -1
      self.launchY =  self.force * sin(self.angle) * -1
    }else{
      self.launchX = self.force * cos(self.angle)
      self.launchY = self.force * sin(self.angle) * -1
    }
  }
}

