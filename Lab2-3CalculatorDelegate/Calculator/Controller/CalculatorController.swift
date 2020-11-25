//
//  CalculatorController.swift
//  Calculator
//
//  Created by Ellone on 29.10.2020.
//  Copyright © 2020 SFEDU. All rights reserved.
//

import UIKit
import Foundation

class CalculatorController: CalculatorDelegate {
    let formatter = NumberFormatter()
    let maximumFractionDigits = 5

    var calculator: Calculator?
    var outputLabel: UILabel
    var viewController: UIViewController
    
    public init(_ calc: Calculator?, _ label: UILabel, _ view: UIViewController) {
        
        calculator = calc
        outputLabel = label
        viewController = view
        // Становимся представителем
        calculator?.delegate = self
        // Очищаем состояние калькулятора
        calculator?.reset();
        
        // Выводим число с одной цифрой
        formatter.minimumIntegerDigits = 1
    }
    
    func calculatorDidUpdateValue(_ calculator: Calculator, with value: Double, valuePrecision fractionDigits: UInt) {
        
        print("Update Result with \(value), \(fractionDigits)")
        
        formatter.minimumFractionDigits = min(Int(fractionDigits), maximumFractionDigits)
        
        if calculator.hasPoint, fractionDigits == 0 {
            // поставили запятую, но не ввели цифры после запятой
            outputLabel.text = formatter.string(from: NSNumber(value: value))! + formatter.decimalSeparator
        } else {
            outputLabel.text = formatter.string(from: NSNumber(value: value))
        }
    }
    
    func calculatorDidClear(_ calculator: Calculator, withDefaultValue value: Double?, defaultPrecision fractionDigits: UInt?) {
        
        print("Clear")
        
        formatter.minimumFractionDigits = min(Int(fractionDigits ?? 0), maximumFractionDigits)
        
        if let inputValue = value {
            outputLabel.text = formatter.string(from: NSNumber(value: inputValue))
        } else {
            outputLabel.text = String()
        }
        
    }
    
    func calculatorDidNotCompute(_ calculator: Calculator, withError message: String) {
        
        print("Computational Error: " + message)
        
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel",style: UIAlertAction.Style.cancel) { action in
                alert.dismiss(animated: true, completion: nil)
            }
        alert.addAction(cancel)
        
        viewController.present(alert, animated: true)
    }
    
    func calculatorDidInputOverflow(_ calculator: Calculator) {
        
        print("Input Overflow")
        
        UIView.animate(withDuration: 0.5,
                       animations: { self.outputLabel.alpha = 0.0 },
                       completion: { (finished) in
                        UIView.animate(withDuration: 0.5) {
                            self.outputLabel.alpha = 1.0
                        }
        })
    }
}
