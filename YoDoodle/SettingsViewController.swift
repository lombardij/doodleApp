//
//  SettingsViewController.swift
//  YoDoodle
//
//  Created by Phillip Fiedler on 12/22/17.
//  Copyright © 2017 Phillip Fiedler. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    var doodleModel: DoodleModel!
    
    @IBOutlet var snakeMode: UISwitch!
    @IBOutlet var snakeLength: UISlider!
    
    @IBOutlet var dotMode: UISwitch!
    @IBOutlet var dotSize: UISlider!
    
    @IBOutlet var lineMode: UISwitch!
    @IBOutlet var lineWidth: UISlider!
    
    @IBOutlet var shakeMode: UISwitch!
    @IBOutlet var shakeMax: UISlider!
    
    @IBOutlet var glowMode: UISwitch!
    @IBOutlet var glowMax: UISlider!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        snakeMode.isOn = doodleModel.isSnakeModeEnabled
        snakeLength.value = Float(doodleModel.snakeLength)
        
        dotMode.isOn = doodleModel.isDotModeEnabled
        dotSize.value = Float(doodleModel.dotSize)
        
        lineMode.isOn = doodleModel.isLineModeEnabled
        lineWidth.value = Float(doodleModel.lineWidth)
        
        shakeMode.isOn = doodleModel.isShakeModeEnabled
        shakeMax.value = Float(doodleModel.shakeMax)
        
        // Add glow
    }

   
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        doodleModel.isSnakeModeEnabled = snakeMode.isOn
        doodleModel.snakeLength = snakeLength.value
        
        doodleModel.isDotModeEnabled = dotMode.isOn
        doodleModel.dotSize = dotSize.value
        
        doodleModel.isLineModeEnabled = lineMode.isOn
        doodleModel.lineWidth = lineWidth.value
        
        doodleModel.isShakeModeEnabled = shakeMode.isOn
        doodleModel.shakeMax = shakeMax.value
        
        // Need to add glow
        
        doodleModel.saveSettings()
    }
    

    
}

