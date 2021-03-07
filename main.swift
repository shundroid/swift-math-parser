import Foundation

enum MError: Error {
  case unexpectedCharacter
  case unexpectedCombination
}

protocol MathUnit {
}

protocol MFormula: MathUnit {
  func combine(newFormula: MFormula) throws -> MFormula
  func calc() -> Int
}

struct MNumber: MFormula {
  var num: Int 
  func combine(newFormula: MFormula) throws -> MFormula {
    switch newFormula {
      case is MNumber:
        return MNumber(num: num * 10 + (newFormula as! MNumber).num)
      case is MOperatorFormula:
        var newOperatorFormula = newFormula as! MOperatorFormula
        newOperatorFormula.mOperator.left = self
        return newOperatorFormula
      default:
        throw MError.unexpectedCombination
    }
  }
  func calc() -> Int {
    return num
  }
}

enum MOperatorType: String {
  case plus = "+"
  case minus = "-"
}
struct MOperator: MathUnit {
  var left: MFormula?
  var right: MFormula?
  var operatorType: MOperatorType
}
struct MOperatorFormula: MFormula {
  var mOperator: MOperator
  func combine(newFormula: MFormula) throws -> MFormula {
    switch newFormula {
      case is MNumber:
        var newOperatorFormula = self
        newOperatorFormula.mOperator.right = newFormula
        return newOperatorFormula
      default:
        throw MError.unexpectedCombination
    }
  }
  func calc() -> Int {
    switch mOperator.operatorType {
      case .plus:
        return self.mOperator.left!.calc() + self.mOperator.right!.calc()
      case .minus:
        return self.mOperator.left!.calc() - self.mOperator.right!.calc()
    }
  }
}

func checkRegEx(text: String, pattern: String) -> Bool {
  guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
  let matches = regex.matches(in: text, range: NSRange(location: 0, length: text.count))
  return matches.count > 0
}
extension String.Element {
  func isNumber() -> Bool {
    return checkRegEx(text: String(self), pattern: "^[\\d]+$")
  }
  func isOperator() -> Bool {
    return checkRegEx(text: String(self), pattern: "^(\\+|\\-)$")
  }
}

// let argv = ProcessInfo.processInfo.arguments
// let input = argv[1]
let input = "123+4"

var currentFormula: MFormula? = nil
for char in input {
  var newFormula: MFormula? = nil
  switch true {
    case char.isNumber():
      newFormula = MNumber(num: char.wholeNumberValue!)
    case char.isOperator():
      var mOperatorType: MOperatorType?
      switch char {
        case "+":
          mOperatorType = .plus
        case "-":
          mOperatorType = .minus
        default:
          throw MError.unexpectedCharacter
      }
      newFormula = MOperatorFormula(mOperator: MOperator(left: nil, right: nil, operatorType: mOperatorType!))
    default:
      throw MError.unexpectedCharacter
  }
  if currentFormula == nil {
    currentFormula = newFormula
  } else {
    currentFormula = try currentFormula?.combine(newFormula: newFormula!)
  }
}

print(currentFormula!.calc())
