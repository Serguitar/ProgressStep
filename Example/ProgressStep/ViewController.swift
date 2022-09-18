//
//  ViewController.swift
//  ProgressStep
//
//  Created by Sergey Lukoyanov on 08/28/2017.
//  Copyright (c) 2017 Sergey Lukoyanov. All rights reserved.
//

import UIKit
import ProgressStep

class ViewController: UIViewController {

    @IBOutlet weak var progressView: ProgressStep!
    @IBOutlet weak var valueTF: UITextField!
    
    var currentValue: CGFloat = 0.0
    
    @IBAction func addTapped(_ sender: Any) {
        currentValue += 0.5
        valueTF.text = "\(currentValue)"
        progressView.value = currentValue
    }
    
    @IBAction func minusTapped(_ sender: Any) {
        currentValue -= 0.5
        valueTF.text = "\(currentValue)"
        progressView.value = currentValue
    }
}
