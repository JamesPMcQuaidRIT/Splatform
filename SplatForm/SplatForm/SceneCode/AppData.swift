//
//  AppData.swift
//  SplatForm
//
//  Created by student on 12/9/17.
//  Copyright © 2017 splat. All rights reserved.
//

import Foundation

class AppData{
    
    static let sharedData = AppData()
    var lowestBallsUsed:Int = 0{
        didSet{
            let defaults = UserDefaults.standard
            defaults.set(lowestBallsUsed, forKey: ballKey)
        }
    }
    
    let ballKey = "lowestBallsUsed"
    
    private init(){
        print("Created AppData instance")
        readDefaultsData()
    }
    
    private func readDefaultsData(){
        let defaults = UserDefaults.standard
        lowestBallsUsed = defaults.integer(forKey: ballKey)
    }
}
