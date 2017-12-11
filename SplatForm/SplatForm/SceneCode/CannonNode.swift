//
//  Cannon.swift
//  SplatForm
//
//  Created by student on 12/10/17.
//  Copyright © 2017 splat. All rights reserved.
//

import Foundation
import SpriteKit

class Cannon: SKSpriteNode{
  var base:SKNode?
  var barrel:SKNode?
  var angle:CGFloat = 0
  var positionX:CGFloat = 0
  var positionY: CGFloat = 0
  let radianConversion = CGFloat.pi/180
  var loaded:Bool = false
  var primed:Bool = false
  var force:CGFloat = 1250
  var launchX:CGFloat = 0
  var launchY:CGFloat = 0
  
  init() {
    // super.init()
    //self.base = nil
    //self.barrel = nil
    self.angle = 0
    print("end of init")
    //let canSize = CGSize.init()
    super.init(texture: .init(), color: .gray, size: CGSize.init())
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  func setBarrel(barrelIn: SKSpriteNode){
    self.barrel = barrelIn
    self.positionX = barrelIn.position.x
    self.positionY = barrelIn.position.y
  }
  
  func setBase(baseIn: SKSpriteNode){
    self.base = baseIn
    
  }
  func calcAngle(touchX: CGFloat, touchY: CGFloat){
    let dX = self.positionX - touchX
    let dY = self.positionY - touchY
    let distAngle = atan2(dY,dX)
    self.barrel!.zRotation = angle + radianConversion
    self.angle = distAngle + radianConversion
  }
  
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
  
  func fireCannon(){
    self.loaded = false
    self.primed = false
    
    if(self.angle != 0){
      self.launchX =  self.force * cos(self.angle) * -1
      self.launchY =  self.force * sin(self.angle) * -1
    }else{
      self.launchX = self.force * cos(self.angle)
      self.launchY = self.force * sin(self.angle) * -1
    }
  }
}

