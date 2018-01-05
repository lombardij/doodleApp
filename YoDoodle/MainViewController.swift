//
//  MainViewController.swift
//  YoDoodle
//
//  Created by Phillip Fiedler on 12/22/17.
//  Copyright © 2017 Phillip Fiedler. All rights reserved.
//

import UIKit

class MainViewController: UIViewController
{
    @IBOutlet var doodleView: DoodleView!
    
    let doodleModel = DoodleModel()
    let doodlePeer = DoodlePeer()
    
    var shakeTimer: Timer! = nil
    

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        doodleView.frame = self.view.frame
        
        if let viewControllers = self.tabBarController?.viewControllers
        {
            for vc in viewControllers
            {
                if vc is SettingsViewController
                {
                    let settingsVC: SettingsViewController = (vc as? SettingsViewController)!
                    settingsVC.doodleModel = self.doodleModel
                }
            }
        }
        
        doodleView.doodleModel = self.doodleModel
        doodleView.doodlePeer = self.doodlePeer
        
        doodlePeer.delegate = self
    }
    

    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        checkDrawEffects()
    }
    
    
    @IBAction func clearDoodle(_ sender: Any)
    {
        doodleModel.clearDoodle()
        doodleView.setNeedsDisplay()
    }
    
    
    func checkDrawEffects()
    {
        if doodleModel.isShakeModeEnabled && shakeTimer == nil
        {
            self.shakeTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.shakePoints), userInfo: nil, repeats: true)
        }
        
//        if doodleModel.isShakeModeEnabled && shakeTimer == nil
//        {
//            self.shakeTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.shakePoints), userInfo: nil, repeats: true)
//        }
//        else if !doodleModel.isShakeModeEnabled && self.shakeTimer != nil
//        {
//            self.shakeTimer.invalidate()
//            self.shakeTimer = nil
//        }
    }
    
    
    @objc func shakePoints()
    {
        doodleModel.shakePoints()
        doodleView.setNeedsDisplay()
    }
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

}


extension MainViewController : DoodlePeerDelegate
{
    func connectedDevicesChanged(manager: DoodlePeer, connectedDevices: [String])
    {
        OperationQueue.main.addOperation
        {
            NSLog("Connections: \(connectedDevices)")
        }
    }
    
    func drawPtAdded(manager: DoodlePeer, drawPtString: String)
    {
        OperationQueue.main.addOperation
        {
            self.doodleModel.addPoint(point: CGPointFromString(drawPtString))
            self.doodleView.setNeedsDisplay()
        }
    }
}
