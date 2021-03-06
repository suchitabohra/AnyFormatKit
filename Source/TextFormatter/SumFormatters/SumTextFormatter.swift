//
//  SumTextFormatter.swift
//  AnyFormatKit
//
//  Created by BRANDERSTUDIO on 10.11.2017.
//  Copyright © 2017 BRANDERSTUDIO. All rights reserved.
//

import Foundation

open class SumTextFormatter: TextFormatterProtocol {
  
  private let numberFormatter: NumberFormatter
  
  open var maximumIntegerCharacters: Int = 14 {
    didSet { numberFormatter.maximumIntegerDigits = maximumIntegerCharacters }
  }
  open var maximumDecimalCharacters: Int {
    return numberFormatter.maximumFractionDigits
  }
  open var suffix: String? {
    guard !numberFormatter.positiveSuffix.isEmpty else { return nil }
    return numberFormatter.positiveSuffix
  }
  open var prefix: String? {
    guard !numberFormatter.positivePrefix.isEmpty else { return nil }
    return numberFormatter.positivePrefix
  }
  open var groupingSeparator: String {
    return numberFormatter.groupingSeparator
  }
  open var decimalSeparator: String {
    return numberFormatter.decimalSeparator
  }
  open var groupingSize: Int {
    return numberFormatter.groupingSize
  }
  
  public init(numberFormatter: NumberFormatter) {
    self.numberFormatter = numberFormatter
  }
  
  public init(textPattern: String, patternSymbol: Character = "#") {
    let formatParser = SumFormatParser()
    let result = formatParser.parse(format: textPattern, patternSymbol: patternSymbol)
    let numberFormatter = NumberFormatter()
    numberFormatter.positivePrefix = result.prefix
    numberFormatter.positiveSuffix = result.suffix
    numberFormatter.groupingSeparator = result.groupingSeparator
    numberFormatter.decimalSeparator = result.decimalSeparator
    numberFormatter.groupingSize = result.groupingSize
    numberFormatter.maximumFractionDigits = result.maximumFractionDigits
    numberFormatter.minimumIntegerDigits = 1
    numberFormatter.allowsFloats = true
    numberFormatter.usesGroupingSeparator = true
    numberFormatter.roundingMode = .down
    numberFormatter.negativePrefix = result.prefix + "-"
    self.numberFormatter = numberFormatter
  }
  
  
  private let unformattedDecimalSeparator = "."
  private let negativePrefix = "-"
  
  open func formattedText(from unformatted: String?) -> String? {
    guard let unformatted = unformatted else { return nil }
    guard !unformatted.isEmpty else { return suffix ?? "" }
    guard unformatted != negativePrefix else { return negativePrefix }
    
    var correctedUnformatted = correctUnformatted(unformatted, decimalSeparator: unformattedDecimalSeparator)
    correctedUnformatted = correctUnformatted(correctedUnformatted, maximumIntegerDigits: maximumIntegerCharacters, decimalSeparator: unformattedDecimalSeparator, negativePrefix: negativePrefix)
    let number = NSDecimalNumber(string: correctedUnformatted)
    let minimumFractionDigits = calculateMinimumFractionDigits(unformatted: correctedUnformatted, divider: ".", maximumFractionDigits: numberFormatter.maximumFractionDigits)
    numberFormatter.minimumFractionDigits = minimumFractionDigits
    let needAlwaysShowDecimalSeparator = minimumFractionDigits == 0 && correctedUnformatted.contains(unformattedDecimalSeparator)
    numberFormatter.alwaysShowsDecimalSeparator = needAlwaysShowDecimalSeparator
    return numberFormatter.string(from: number)
  }
  
  private func correctUnformatted(_ unformatted: String, decimalSeparator: String) -> String {
    return unformatted.replacingOccurrences(of: ",", with: decimalSeparator)
  }
  
  private func correctUnformatted(_ unformatted: String, maximumIntegerDigits: Int, decimalSeparator: String, negativePrefix: String) -> String {
    let decimalPart = unformatted.sliceBefore(substring: decimalSeparator)
    let floatingPart = unformatted.sliceAfter(substring: decimalSeparator)
    let correctedDecimalPart = correctUnformattedDecimalPart(decimalPart, maximumIntegerDigits: maximumIntegerDigits, negativePrefix: negativePrefix)
    if unformatted.contains(decimalSeparator) {
      return correctedDecimalPart + decimalSeparator + floatingPart
    } else {
      return correctedDecimalPart
    }
  }
  
  private func correctUnformattedDecimalPart(_ decimalPart: String, maximumIntegerDigits: Int, negativePrefix: String) -> String {
    if !negativePrefix.isEmpty && decimalPart.contains(negativePrefix) {
      return decimalPart.leftSlice(limit: maximumIntegerDigits + negativePrefix.count)
    } else {
      return decimalPart.leftSlice(limit: maximumIntegerDigits)
    }
  }
  
  private func calculateMinimumFractionDigits(unformatted: String, divider: Character, maximumFractionDigits: Int) -> Int {
    let currentFractionDigitsCount = getFractionDigitsCount(unformatted: unformatted, divider: divider)
    if currentFractionDigitsCount >= maximumFractionDigits { return maximumFractionDigits }
    return currentFractionDigitsCount
  }
  
  private func getFractionDigitsCount(unformatted: String, divider: Character) -> Int {
    let parts = unformatted.split(separator: divider)
    guard parts.count > 1 else { return 0 }
    return parts[1].count
  }
  
  open func unformattedText(from formatted: String?) -> String? {
    guard let formatted = formatted else { return nil }
    let formattedString = formatted
    
    let unformattedString = formattedString
      .replacingOccurrences(of: suffix ?? "", with: "")
      .replacingOccurrences(of: prefix ?? "", with: "")
      .replacingOccurrences(of: " ", with: "")
      .replacingOccurrences(of: groupingSeparator, with: "")
    
    return unformattedString
  }
}
