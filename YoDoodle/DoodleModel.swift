//
//  DoodleModel.swift
//  YoDoodle
//
//  Created by Phillip Fiedler on 12/23/17.
//  Copyright © 2017 Phillip Fiedler. All rights reserved.
//

import UIKit

class DoodleModel: NSObject
{
    var doodleArray = NSMutableArray()
    
    // Global Draw Mode/Effect Vars
    
    var isSnakeModeEnabled: Bool = true
    var snakeLength: Int = 50
    
    var isDotModeEnabled: Bool = true
    var dotSize: Float = 8
    
    var isLineModeEnabled: Bool = false
    var lineWidth: Float = 3
    
    var isShakeModeEnabled: Bool = false
    var shakeMax: Float = 4
    
    
    override init()
    {
        super.init()
        
        if !UserDefaults.standard.bool(forKey: "Initialized")
        {
            self.resetSettingsToDefaults()
            UserDefaults.standard.set(true, forKey: "Initialized")
        }
        else
        {
            self.loadSettings()
        }
    }
    
    
    func addPoint(point: CGPoint)
    {
        doodleArray.add(point)
        
        while isSnakeModeEnabled && doodleArray.count > snakeLength
        {
            doodleArray.removeObjects(at: [0])
        }
    }
    
    
    func shakePoints()
    {
        var drawPt: CGPoint!
        
        for index in 0..<doodleArray.count
        {
            drawPt = doodleArray[index] as? CGPoint
            
            let newX: Float = Float(drawPt.x) + Float(arc4random_uniform(UInt32(shakeMax))) - (shakeMax-1)/2.0
            let newY: Float = Float(drawPt.y) + Float(arc4random_uniform(UInt32(shakeMax))) - (shakeMax-1)/2.0

            doodleArray.replaceObject(at: index, with: CGPoint(x: CGFloat(newX), y: CGFloat(newY)))
        }
    }
    
    
    func clearDoodle()
    {
        doodleArray.removeAllObjects()
    }
    
    
    func loadSettings()
    {
        isSnakeModeEnabled = UserDefaults.standard.bool(forKey: "isSnakeModeEnabled")
        snakeLength = UserDefaults.standard.integer(forKey: "snakeLength")
        
        isDotModeEnabled = UserDefaults.standard.bool(forKey: "isDotModeEnabled")
        dotSize = UserDefaults.standard.float(forKey: "dotSize")
        
        isLineModeEnabled = UserDefaults.standard.bool(forKey: "isLineModeEnabled")
        lineWidth = UserDefaults.standard.float(forKey: "lineWidth")
        
        isShakeModeEnabled = UserDefaults.standard.bool(forKey: "isShakeModeEnabled")
        shakeMax = UserDefaults.standard.float(forKey: "shakeMax")
    }
    
    
    func saveSettings()
    {
        UserDefaults.standard.set(isSnakeModeEnabled, forKey: "isSnakeModeEnabled")
        UserDefaults.standard.set(snakeLength, forKey: "snakeLength")
 
        UserDefaults.standard.set(isDotModeEnabled, forKey: "isDotModeEnabled")
        UserDefaults.standard.set(dotSize, forKey: "dotSize")

        UserDefaults.standard.set(isLineModeEnabled, forKey: "isLineModeEnabled")
        UserDefaults.standard.set(lineWidth, forKey: "lineWidth")
        
        UserDefaults.standard.set(isShakeModeEnabled, forKey: "isShakeModeEnabled")
        UserDefaults.standard.set(shakeMax, forKey: "shakeMax")
   }
    
    
    func resetSettingsToDefaults()
    {
        UserDefaults.standard.set(true, forKey: "isSnakeModeEnabled")
        UserDefaults.standard.set(50, forKey: "snakeLength")
        
        UserDefaults.standard.set(true, forKey: "isDotModeEnabled")
        UserDefaults.standard.set(8, forKey: "dotSize")
        
        UserDefaults.standard.set(false, forKey: "isLineModeEnabled")
        UserDefaults.standard.set(3, forKey: "lineWidth")
        
        UserDefaults.standard.set(false, forKey: "isShakeModeEnabled")
        UserDefaults.standard.set(4, forKey: "shakeMax")
    }
    
}
