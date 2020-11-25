//
//  CalculatorDelegate.swift
//  Calculator
//
//  Created by Ellone on 29.10.2020.
//  Copyright © 2020 SFEDU. All rights reserved.
//

import Foundation

/// Протокол делегата для калькулятора
public protocol CalculatorDelegate: class {
    
    /// Калькулятор обновил поле ввода
    func calculatorDidUpdateValue(_ calculator: Calculator, with value: Double, valuePrecision fractionDigits: UInt)
    
    /// Калькулятор очистил хранимые значения, установив значения по умолчанию
    func calculatorDidClear(_ calculator: Calculator, withDefaultValue value: Double?, defaultPrecision fractionDigits: UInt?)
    
    // MARK: Ошибки
    
    /// Переполнение поля ввода
    func calculatorDidInputOverflow(_ calculator: Calculator)
    
    /// Ошибка вычислений
    func calculatorDidNotCompute(_ calculator: Calculator, withError message: String)
}
