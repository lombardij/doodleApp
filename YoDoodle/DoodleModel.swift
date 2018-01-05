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
    var doodleArray = [DoodleMark]()
    
    // Global/Current Draw Mode & Effect
    
    var isSnakeModeEnabled: Bool = true
    var snakeLength: Float = 50
    
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
        let doodleMark = DoodleMark(touchPoint: point)
        
        if isDotModeEnabled {
            doodleMark.addDrawMode(newDrawMode: DrawMode(drawMethod: DrawMethod.DOT, drawValue: dotSize))
        }
        if isLineModeEnabled {
            doodleMark.addDrawMode(newDrawMode: DrawMode(drawMethod: DrawMethod.LINE, drawValue: lineWidth))
        }
        if isShakeModeEnabled {
            doodleMark.addDrawMode(newDrawMode: DrawMode(drawMethod: DrawMethod.SHAKE, drawValue: shakeMax))
        }
        
        doodleArray.append(doodleMark)
        
        while isSnakeModeEnabled && (doodleArray.count > Int(snakeLength))
        {
            doodleArray.remove(at: 0)
        }
    }
    
    
    func shakePoints()
    {
        var doodleMark: DoodleMark!
        var snakeSize: Float
        
        for index in 0..<doodleArray.count
        {
            doodleMark = doodleArray[index]
            
            snakeSize = doodleMark.doesMarkInclude(drawMethod: DrawMethod.SHAKE)
            
            if snakeSize > -1
            {
                let newX: Float = Float(doodleMark.point.x) + Float(arc4random_uniform(UInt32(snakeSize))) - (snakeSize-1)/2.0
                let newY: Float = Float(doodleMark.point.y) + Float(arc4random_uniform(UInt32(snakeSize))) - (snakeSize-1)/2.0
                
                doodleMark.point = CGPoint(x: CGFloat(newX), y: CGFloat(newY))
            }
        }
    }
    
    
    func clearDoodle()
    {
        doodleArray.removeAll()
    }
    
    
    func loadSettings()
    {
        isSnakeModeEnabled = UserDefaults.standard.bool(forKey: "isSnakeModeEnabled")
        snakeLength = UserDefaults.standard.float(forKey: "snakeLength")
        
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


class DoodleMark
{
    var point: CGPoint!
    var color: UIColor!
    var drawMode = [DrawMode]()
    
    init(touchPoint: CGPoint)
    {
        self.point = touchPoint
        self.color = UIColor.black
    }
    
    func addDrawMode(newDrawMode: DrawMode)
    {
        self.drawMode.append(newDrawMode)
    }
    
    func doesMarkInclude(drawMethod: DrawMethod) -> Float
    {
        for mode:DrawMode in self.drawMode
        {
            if mode.drawMethod == drawMethod
            {
                return mode.drawValue
            }
        }
        return -1
    }
}

struct DrawMode
{
    var drawMethod: DrawMethod
    var drawValue: Float
}

enum DrawMethod
{
    case DOT
    case LINE
    case SHAKE
}

