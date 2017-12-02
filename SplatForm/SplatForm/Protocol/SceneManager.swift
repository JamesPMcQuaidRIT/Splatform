//
//  SceneManager.swift
//  Shooter1
//
//  Created by student on 10/26/17.
//  Copyright © 2017 JamesMcQuaid. All rights reserved.
//

import Foundation

protocol SceneManager{
    func loadGameScene(levelNum: Int)
    func reloadGameScene(levelNum: Int)
}
