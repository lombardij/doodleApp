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

        context?.setLineWidth(CGFloat(doodleModel.lineWidth))
        context?.setFillColor(UIColor.red.cgColor)
        
        var drawPt: CGPoint!
        var drawPt2: CGPoint!
        
        for index in 0..<doodleModel.doodleArray.count
        {
            drawPt = doodleModel.doodleArray[index] as? CGPoint
            
            if doodleModel.isLineModeEnabled && index > 0
            {
                drawPt2 = doodleModel.doodleArray[index - 1] as? CGPoint
                
                context?.move(to: drawPt)
                context?.addLine(to: drawPt2)
                context?.strokePath()
            }
            
            if doodleModel.isDotModeEnabled
            {
                let circleRect = CGRect(x: CGFloat(drawPt.x) - CGFloat(doodleModel.dotSize/2.0),
                                        y: CGFloat(drawPt.y) - CGFloat(doodleModel.dotSize/2.0),
                                        width: CGFloat(doodleModel.dotSize),
                                        height: CGFloat(doodleModel.dotSize))
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

