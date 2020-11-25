//
//  CalculatorModel.swift
//  Calculator
//
//  Created by Ellone on 29.10.2020.
//  Copyright © 2020 SFEDU. All rights reserved.
//

import Foundation

public class CalculatorModel: Calculator {
    var maxInputLength: UInt
    var maxFraction: UInt
    
    public required init(inputLength len: UInt, maxFraction frac: UInt) {
        self.maxInputLength = len
        self.maxFraction = frac
        self.hasPoint = false
        self.fractionDigits = 0
        self.fractionDigitsRes = 0
        self.fractionDigitsLeft = 0
        self.isComputed = false
        self.isResult = false
        self.newOp = false
    }
    
    private var isComputed: Bool
    private var isResult: Bool
    private var newOp: Bool
    
    public var result: Double?
    public var inputLeft: Double?
    
    public var operation: Operation?
    
    public var input: Double?
    
    public func addDigit(_ d: Int) {
        if let input = self.input, input != 0,
           UInt(log10(abs(input)) + 1) >= maxInputLength {
            delegate?.calculatorDidInputOverflow(self)
            return
        }
        
        self.isResult = false
        
        if self.isComputed {
            inputClear()
            self.isComputed = false
            self.newOp = true
        }

        if hasPoint {
            if fractionDigits + 1 <= self.maxFraction{
                fractionDigits += 1
                input = (input ?? 0) + Double(d)*pow(10, -Double(fractionDigits))
            }
        } else {
            input = (input ?? 0) * 10 + Double(d)
        }
        delegate?.calculatorDidUpdateValue(self, with: input!, valuePrecision: fractionDigits)
    }
    
    public func addPoint() {
        if self.isComputed {
            inputClear()
            input = 0
            self.isComputed = false
        }
        self.hasPoint = true
        delegate?.calculatorDidUpdateValue(self, with: input!, valuePrecision: fractionDigits)
    }
    
    public var hasPoint: Bool
    
    public var fractionDigits: UInt
    public var fractionDigitsRes: UInt
    public var fractionDigitsLeft: UInt
    
    func priority(_ op: Operation) -> UInt {
        if op == Operation.sign
            || op == Operation.perc {
            return 0
        }
        return op == Operation.add || op == Operation.sub ? 1 : 2
    }
    
    public func addOperation(_ op: Operation) {
        if self.input != nil {
            if priority(op) == 0 { //Unary
                var value = isResult ? self.result! : self.input!
                var valFrac = isResult ? self.fractionDigitsRes : self.fractionDigits
                
                if op == Operation.sign {
                    value = -value
                }
                if op == Operation.perc{
                    if valFrac == 0 {
                        if Int(value) % 100 != 0 {
                            valFrac += Int(value) % 10 == 0 ? 1 : 2
                                hasPoint = true
                        }
                    } else {
                        valFrac += 2
                    }
                    valFrac = min(valFrac, self.maxFraction)
                    value = value / 100
                }
                
                if isResult {
                    self.result = value
                    self.fractionDigitsRes = valFrac
                } else {
                    self.input = value
                    self.fractionDigits = valFrac
                }
                delegate?.calculatorDidUpdateValue(self, with: value, valuePrecision: valFrac)
                self.isComputed = true
                return
            }
            
            if self.operation != nil && self.newOp {
                compute()
                self.newOp = false
            }
            self.operation = op
            
            inputToLeft()
            self.isComputed = true
        }
    }
    
    public func compute() {
        if var left = self.inputLeft,
            let op = self.operation
        {
            var fracLeft = self.fractionDigitsLeft
            if self.result != nil {
                resultToLeft()
                left = self.inputLeft!
                fracLeft = self.fractionDigitsLeft
                clearResult()
            }
            
            let input = (self.input ?? left) //must think
            let inputFrac = self.input != nil ? self.fractionDigits : fracLeft
            
            switch op {
            case Operation.add:
               self.result = left + input
               self.fractionDigitsRes = max(fracLeft, inputFrac)
            case Operation.sub:
                self.result = left - input
                self.fractionDigitsRes = max(fracLeft, inputFrac)
            case Operation.mul:
                self.result = left * input
                self.fractionDigitsRes = min(self.maxFraction, fracLeft + inputFrac)
            case Operation.div:
                if input == 0 {
                    delegate?.calculatorDidNotCompute(self, withError: "Divided by zero")
                    return
                }
                self.result = left / input
                
                if fracLeft == 0 && inputFrac == 0 && Int(left) % Int(input) == 0 {
                    self.fractionDigitsRes = 0
                } else {
                    self.fractionDigitsRes = self.maxFraction
                }
            default:
                delegate?.calculatorDidNotCompute(self, withError: "Unknown operation")
            }
            delegate?.calculatorDidUpdateValue(self, with: self.result!, valuePrecision: self.fractionDigitsRes)
            self.isResult = true
            return
        }
    }
    
    func inputClear(){
        input = nil
        hasPoint = false
        fractionDigits = 0
    }
    
    func inputClearLeft(){
        inputLeft = nil
        fractionDigitsLeft = 0
    }
    
    func inputToLeft(){
        self.inputLeft = self.input
        self.fractionDigitsLeft = self.fractionDigits
    }
    
    func resultToLeft(){
        self.inputLeft = self.result
        self.fractionDigitsLeft = self.fractionDigitsRes
    }
    
    public func clear() {
        inputClear()
        delegate?.calculatorDidClear(self, withDefaultValue: 0, defaultPrecision: fractionDigits)
    }
    
    func clearResult(){
        result = nil
        fractionDigitsRes = 0
    }
    
    public func reset() {
        inputClearLeft()
        clearResult()
        operation = nil
        clear()
        isComputed = false
        newOp = false
    }
    
    public var delegate: CalculatorDelegate?
    
}
