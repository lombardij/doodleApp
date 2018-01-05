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
    
    
    override func draw(_ rect: CGRect)
    {
        let context = UIGraphicsGetCurrentContext()
        context?.setAllowsAntialiasing(true)
                
        for index in 0..<doodleModel.doodleArray.count
        {
            let doodleMark = doodleModel.doodleArray[index]
            context?.setFillColor(doodleMark.color.cgColor)
            
            let lineWidth = doodleMark.doesMarkInclude(drawMethod: DrawMethod.LINE)
            
            if lineWidth > -1 && index > 0
            {
                context?.setLineWidth(CGFloat(lineWidth))
                
                let doodleMark2 = doodleModel.doodleArray[index - 1]
                
                context?.move(to: doodleMark.point)
                context?.addLine(to: doodleMark2.point)
                context?.strokePath()
            }
            
            let dotSize = doodleMark.doesMarkInclude(drawMethod: DrawMethod.DOT)

            if dotSize > -1
            {
                let circleRect = CGRect(x: CGFloat(doodleMark.point.x) - CGFloat(dotSize/2.0),
                                        y: CGFloat(doodleMark.point.y) - CGFloat(dotSize/2.0),
                                        width: CGFloat(dotSize),
                                        height: CGFloat(dotSize))
                context?.fillEllipse(in: circleRect)
            }
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if touchBusy { return }
        
        touchBusy = true
        
        let touch = touches.first!
        let location = touch.location(in: self)
        
        doodleModel.addPoint(point: location)
        doodlePeer.send(drawPt: location)
        
        self.setNeedsDisplay()
        
        touchBusy = false
    }
    
    
}

