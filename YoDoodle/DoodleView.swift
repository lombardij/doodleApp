//
//  DoodleView.swift
//  YoDoodle
//
//  Created by Phillip Fiedler on 12/22/17.
//  Copyright © 2017 Phillip Fiedler. All rights reserved.
//

import UIKit

class DoodleView: UIView {
    
    var doodleModel: DoodleModel!
    var doodlePeer: DoodlePeer!
    
    var touchBusy: Bool = false
    var colorBox: ColorBox = ColorBox(iconRect: CGRect(x:0,y:0,width:0,height:0),
                                      fullRect: CGRect(x:0,y:0,width:0,height:0),
                                      active: false, color: UIColor.red, touchPt: CGPoint(x:0,y:0))
    
    
    override func draw(_ rect: CGRect)
    {
        let context = UIGraphicsGetCurrentContext()
        context?.setAllowsAntialiasing(true)
        context?.setLineCap(.round)
        
        for index in 0..<doodleModel.doodleArray.count
        {
            let doodleMark = doodleModel.doodleArray[index]                                             // Pull doodleMark Object from Array
            
            context?.setFillColor(doodleMark.color.cgColor)                                             // Set the current fill and stroke
            context?.setStrokeColor(doodleMark.color.cgColor)                                           // colors for this point/mark
            
            //-----------
            
            let lineWidth = doodleMark.doesMarkInclude(drawMethod: DrawMethod.LINE)                     // SEE if mark specifies LINE draw
            
            if lineWidth > -1 && !doodleMark.isBeginPt && index > 0                                     // If mark includes drawing as a line
            {
                context?.setLineWidth(CGFloat(lineWidth))
                
                let doodleMark2 = doodleModel.doodleArray[index - 1]
                
                context?.move(to: CGPoint(x: doodleMark.point.x + doodleMark.shakeOffset.x,
                                          y: doodleMark.point.y + doodleMark.shakeOffset.y))
                    context?.addLine(to: CGPoint(x: doodleMark2.point.x + doodleMark2.shakeOffset.x,
                                                 y: doodleMark2.point.y + doodleMark2.shakeOffset.y))
                context?.strokePath()
            }
            
            //-----------
            
            let dotSize = doodleMark.doesMarkInclude(drawMethod: DrawMethod.DOT)                        // SEE if mark specifies DOT draw

            if dotSize > -1
            {
                let circleRect = CGRect(x: CGFloat(doodleMark.point.x + doodleMark.shakeOffset.x) - CGFloat(dotSize/2.0),
                                        y: CGFloat(doodleMark.point.y + doodleMark.shakeOffset.y) - CGFloat(dotSize/2.0),
                                        width: CGFloat(dotSize),
                                        height: CGFloat(dotSize))
                context?.fillEllipse(in: circleRect)
            }
            
            //-----------
        }
        
        if colorBox.active
        {
            drawColorBox()                                                      // Show expanded full size colorbox
        }
        else                                                                    // Else show icon/square of current color
        {
            context?.setFillColor(doodleModel.currentColor.cgColor)
            context?.fill(colorBox.iconRect)
        }
    }
    
    
    func drawColorBox()
    {
        let context = UIGraphicsGetCurrentContext()
        let colorWidth = colorBox.fullRect.size.width / CGFloat(colorBox.colorArray.count)

        for index in 0..<colorBox.colorArray.count
        {
            let color = colorBox.colorArray[index]
            context?.setFillColor(color.cgColor)

            context?.fill(CGRect(x: colorBox.fullRect.minX + CGFloat(index) * colorWidth, y: colorBox.fullRect.minY,
                                 width: colorWidth, height: colorBox.fullRect.size.height))
        }
        
        if colorBox.fullRect.contains(colorBox.touchPt)
        {
            let colorIndex: Int = Int(CGFloat(Float((colorBox.touchPt.x - colorBox.fullRect.minX) / (colorBox.fullRect.size.width))) * CGFloat(colorBox.colorArray.count))
            
            for index in 0..<colorBox.colorArray.count
            {
                if index == colorIndex
                {
                    context?.setLineWidth(CGFloat(5))
                    context?.setStrokeColor(UIColor.white.cgColor)
                    context?.stroke(CGRect(x: colorBox.fullRect.minX + CGFloat(index) * colorWidth, y: colorBox.fullRect.minY,
                                           width: colorWidth, height: colorBox.fullRect.size.height))
                }
            }
        }
    }
    
    
    func updateColorBox(viewRect: CGRect)
    {
        self.colorBox.iconRect = CGRect(x: 30, y: viewRect.height - 100 , width: 30, height: 30)
        self.colorBox.fullRect = CGRect(x: 30, y: viewRect.height - 150,
                                        width: self.frame.size.width - 60, height: 30)
        self.setNeedsDisplay()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        let touch = touches.first!
        let point = touch.location(in: self)

        if colorBox.iconRect.contains(point)
        {
            colorBox.active = true
        }
        else
        {
            let doodleMark = doodleModel.addPoint(point: point)
            doodleMark.isBeginPt = true
            doodlePeer.send(doodleMark: doodleMark)
        }
        
        self.setNeedsDisplay()
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if touchBusy { return }
        
        touchBusy = true
        
        let touch = touches.first!
        let point = touch.location(in: self)
        
        if colorBox.active
        {
            colorBox.touchPt = point
        }
        else
        {
            let doodleMark = doodleModel.addPoint(point: point)
            doodlePeer.send(doodleMark: doodleMark)
        }
        
        self.setNeedsDisplay()
        touchBusy = false
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        let touch = touches.first!
        let point = touch.location(in: self)

        if colorBox.active
        {
            if colorBox.fullRect.contains(point)
            {
                let colorWidth = colorBox.fullRect.size.width / CGFloat(colorBox.colorArray.count)
                let index: Int = Int((point.x - colorBox.fullRect.minX) / colorWidth)
                
                colorBox.color = colorBox.colorArray[index]
                doodleModel.currentColor = colorBox.color
                
                UserDefaults.standard.set(doodleModel.currentColor.toRGBAString(), forKey: "currentColor")
             }
            
            colorBox.active = false
        }
        
        self.setNeedsDisplay()
    }
}


struct ColorBox
{
    var iconRect: CGRect
    var fullRect: CGRect
    var active: Bool
    var color: UIColor
    var touchPt: CGPoint
    let colorArray = [ UIColor.red, UIColor.green, UIColor.blue, UIColor.yellow, UIColor.black, UIColor.white ]
}
