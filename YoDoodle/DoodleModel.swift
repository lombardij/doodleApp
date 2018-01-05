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
    
    var currentColor: UIColor = UIColor.red
    
    
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
    
    
    func addPoint(point: CGPoint) -> DoodleMark
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
        
        doodleMark.color = currentColor
        
        doodleArray.append(doodleMark)
        
        while isSnakeModeEnabled && (doodleArray.count > Int(snakeLength))
        {
            doodleArray.remove(at: 0)
        }
        
        return doodleMark
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
    
    
    func createDoodleMarkFromString(doodleMarkString: String)
    {
        let doodleMark = DoodleMark(touchPoint: CGPoint(x:0, y:0))
        
        let doodleParms = doodleMarkString.components(separatedBy: "|")
        
        for parm in doodleParms
        {
            let keyValue = parm.components(separatedBy: ":")
            
            switch keyValue[0]
            {
                case "Point":
                    doodleMark.point = CGPointFromString(keyValue[1])
                
                case "Color":
                    doodleMark.color = UIColor.init(rgbaString: keyValue[1])
                
                case "DrawMode":
                    let dModeKeyValue = keyValue[1].components(separatedBy: ",")
                    
                    switch dModeKeyValue[0]
                    {
                        case "DOT":
                            doodleMark.addDrawMode(newDrawMode: DrawMode(drawMethod: DrawMethod.DOT, drawValue: Float(dModeKeyValue[1])!))
                        case "LINE":
                            doodleMark.addDrawMode(newDrawMode: DrawMode(drawMethod: DrawMethod.LINE, drawValue: Float(dModeKeyValue[1])!))
                        case "SHAKE":
                            doodleMark.addDrawMode(newDrawMode: DrawMode(drawMethod: DrawMethod.SHAKE, drawValue: Float(dModeKeyValue[1])!))
                        default:
                            doodleMark.addDrawMode(newDrawMode: DrawMode(drawMethod: DrawMethod.DOT, drawValue: 3))
                    }
                
                default:
                    NSLog("no defaults")
            }
        }
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
    
    var toString: String
    {
        var objString = String(format: "Point:{%.1f,%.1f}|", point.x, point.y)
        objString += "Color:\(color.toRGBAString())"
        
        for dMode in drawMode
        {
             objString += "|"
            objString += "DrawMode:\(dMode.drawMethod),\(dMode.drawValue)"
        }

        return objString
    }
    
//    var jsonString : String
//    {
//        let colorStr = color.toRGBAString()
//        var dict = [ "point" : String(format: "{%.1f,%.1f}|", point.x, point.y), "color" : colorStr ]
//
//        for index in 0..<drawMode.count
//        {
//            dict["drawmode\(index)"] = drawMode[index].jsonString
//        }
//
//        let data =  try! JSONSerialization.data(withJSONObject: dict, options: [])
//        return String(data:data, encoding:.utf8)!
//    }
    
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
    
    func loadJSON(text: String) -> [String: Any]?
    {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}

struct DrawMode
{
    var drawMethod: DrawMethod
    var drawValue: Float
    
    var jsonString : String
    {
        let dict = [
            "drawMethod" : drawMethod.hashValue,
            "drawValue" : String(format: "%.2f", drawValue),
            ] as [String : Any]
        let data =  try! JSONSerialization.data(withJSONObject: dict, options: [])
        return String(data:data, encoding:.utf8)!
    }
}

enum DrawMethod
{
    case DOT
    case LINE
    case SHAKE
}

extension UIColor
{
    public convenience init?(rgbaString : String)
    {
        self.init(ciColor: CIColor(string: rgbaString))
    }
    
    //Convert UIColor to RGBA String
    func toRGBAString()-> String
    {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return "\(r) \(g) \(b) \(a)"
    }
    
}
