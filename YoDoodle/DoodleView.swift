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
                                      active: false, color: UIColor.red, curPosition: 0)
    
    
    override func draw(_ rect: CGRect)
    {
        let context = UIGraphicsGetCurrentContext()
        context?.setAllowsAntialiasing(true)
        
        for index in 0..<doodleModel.doodleArray.count
        {
            let doodleMark = doodleModel.doodleArray[index]                                             // Pull doodleMark Object from Array
            
            context?.setFillColor(doodleMark.color.cgColor)                                             // Set the current fill and stroke
            context?.setStrokeColor(doodleMark.color.cgColor)                                           // colors for this point/mark
            
            let lineWidth = doodleMark.doesMarkInclude(drawMethod: DrawMethod.LINE)                     // SEE if mark specifies LINE draw
            
            if lineWidth > -1 && index > 0                                                              // If mark includes drawing as a line
            {
                context?.setLineWidth(CGFloat(lineWidth))
                
                let doodleMark2 = doodleModel.doodleArray[index - 1]
                
                context?.move(to: doodleMark.point)
                context?.addLine(to: doodleMark2.point)
                context?.strokePath()
            }
            
            let dotSize = doodleMark.doesMarkInclude(drawMethod: DrawMethod.DOT)                        // SEE if mark specifies DOT draw

            if dotSize > -1
            {
                let circleRect = CGRect(x: CGFloat(doodleMark.point.x) - CGFloat(dotSize/2.0),
                                        y: CGFloat(doodleMark.point.y) - CGFloat(dotSize/2.0),
                                        width: CGFloat(dotSize),
                                        height: CGFloat(dotSize))
                context?.fillEllipse(in: circleRect)
            }
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

            context?.fill(CGRect(x: colorBox.fullRect.minX + CGFloat(index) * colorWidth,
                                 y: colorBox.fullRect.minY,
                                 width: colorWidth,
                                 height: colorBox.fullRect.size.height))
        }
        // draw line/arrow indicating current color
    }
    
    
    func updateColorBox(viewRect: CGRect)
    {
        self.colorBox.iconRect = CGRect(x: 30, y: viewRect.height - 100 , width: 30, height: 30)
        self.colorBox.fullRect = CGRect(x: 30, y: viewRect.height - 100,
                                        width: self.frame.size.width - 60, height: 30)
        self.setNeedsDisplay()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        let touch = touches.first!
        let point = touch.location(in: self)

        if point.x > colorBox.iconRect.minX && point.x < colorBox.iconRect.maxX &&
           point.y > colorBox.iconRect.minY && point.y < colorBox.iconRect.maxY
        {
            colorBox.active = true
            self.setNeedsDisplay()
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if touchBusy { return }
        
        touchBusy = true
        
        let touch = touches.first!
        let point = touch.location(in: self)
        
        if colorBox.active
        {
            colorBox.curPosition = Float((point.x - colorBox.fullRect.minX) / (colorBox.fullRect.size.width))
        }
        else
        {
            doodleModel.addPoint(point: point)
            doodlePeer.send(drawPt: point)
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
            if point.x > colorBox.fullRect.minX && point.x < colorBox.fullRect.maxX &&
                point.y > colorBox.fullRect.minY && point.y < colorBox.fullRect.maxY
            {
                let colorWidth = colorBox.fullRect.size.width / CGFloat(colorBox.colorArray.count)
                
                // Update current color given currentPosition
                // temp
                
                let index: Int = Int((point.x - colorBox.fullRect.minX) / colorWidth)
                
                colorBox.color = colorBox.colorArray[index]
                doodleModel.currentColor = colorBox.color
                
                // save currentColor to user settings
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
    var curPosition: Float
    let colorArray = [ UIColor.red, UIColor.green, UIColor.blue, UIColor.yellow, UIColor.black, UIColor.white ]
}
