//
//  ViewController.swift
//  Calculator
//
//  Created by Ellone on 29.10.2020.
//  Copyright © 2020 Ukolnir. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var calculator: Calculator?
    var delegate: CalculatorDelegate?
    
    @IBOutlet weak var calcLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calculator = (UIApplication.shared.delegate as! AppDelegate).calculator
        delegate = CalculatorController(calculator, calcLabel, self)
    }

    @IBAction func numbers(_ sender: UIButton) {
        guard let title = sender.titleLabel?.text else { return }
        guard let digit = Int(title) else {
            return
        }
        calculator?.addDigit(digit)
    }
    
    @IBAction func addPoint(_ sender: UIButton) {
        calculator?.addPoint()
    }
    
    @IBAction func compute(_ sender: UIButton) {
        calculator?.compute()
    }
    
    @IBAction func sum(_ sender: UIButton) {
        calculator?.addOperation(Operation.add)
    }
    
    @IBAction func sub(_ sender: UIButton) {
        calculator?.addOperation(Operation.sub)
    }
    
    @IBAction func mult(_ sender: UIButton) {
        calculator?.addOperation(Operation.mul)
    }
    
    @IBAction func div(_ sender: UIButton) {
        calculator?.addOperation(Operation.div)
    }
    
    @IBAction func perc(_ sender: UIButton) {
        calculator?.addOperation(Operation.perc)
    }
    
    @IBAction func change(_ sender: UIButton) {
        calculator?.addOperation(Operation.sign)
    }
    
    @IBAction func clear(_ sender: UIButton) {
        if let _ = calculator?.input {
            calculator?.clear();
        } else {
            calculator?.reset();
        }
    }
    
}

