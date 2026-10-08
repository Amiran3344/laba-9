import Foundation

// Лабораторная работа №9

//  A. Direction 
enum Direction: String {
    case north = "N", south = "S", east = "E", west = "W"
    var opposite: Direction {
        switch self {
        case .north: return .south
        case .south: return .north
        case .east: return .west
        case .west: return .east
        }
    }
}
let dir = Direction.north
print(dir.opposite)
print(dir.rawValue)
if let d = Direction(rawValue: "E") { print(d) }

enum HTTPStatus: Int {
    case ok = 200, notFound = 404, serverError = 500
    var description: String {
        switch self {
        case .ok: return "OK"
        case .notFound: return "Not Found"
        case .serverError: return "Server Error"
        }
    }
}
let status = HTTPStatus.ok
print(status.description)

//  B. Coin 
enum Coin {
    case kopeck(Int), ruble(Int), dollar(Int)
}
func totalInRubles(_ coins: [Coin]) -> Double {
    return coins.reduce(0) { total, coin in
        switch coin {
        case .kopeck(let n): return total + Double(n) / 100.0
        case .ruble(let n):  return total + Double(n)
        case .dollar(let n): return total + Double(n) * 90.0
        }
    }
}
print(totalInRubles([.ruble(50), .dollar(1), .kopeck(75), .ruble(10)]))

//  C. MathOperation 
enum MathOperation {
    case add(Double, Double), subtract(Double, Double),
         multiply(Double, Double), divide(Double, Double)
}
enum CalcResult {
    case success(Double), failure(String)
}
func calculate(_ op: MathOperation) -> CalcResult {
    switch op {
    case .add(let a, let b): return .success(a + b)
    case .subtract(let a, let b): return .success(a - b)
    case .multiply(let a, let b): return .success(a * b)
    case .divide(let a, let b):
        return b == 0 ? .failure("Деление на ноль") : .success(a / b)
    }
}
switch calculate(.add(3, 5)) {
case .success(let v): print("Результат: \(v)")
case .failure(let m): print("Ошибка: \(m)")
}
switch calculate(.divide(10, 0)) {
case .success(let v): print("Результат: \(v)")
case .failure(let m): print("Ошибка: \(m)")
}

// D. FileSystemItem
indirect enum FileSystemItem {
    case file(name: String, size: Int)
    case folder(name: String, contents: [FileSystemItem])
}
func totalSize(_ item: FileSystemItem) -> Int {
    switch item {
    case .file(_, let size): return size
    case .folder(_, let contents): return contents.map(totalSize).reduce(0, +)
    }
}
func printTree(_ item: FileSystemItem, indent: String = "") {
    switch item {
    case .file(let name, let size):
        print("\(indent)\(name) (\(size))")
    case .folder(let name, let contents):
        print("\(indent)\(name)/")
        for child in contents { printTree(child, indent: indent + "  ") }
    }
}
let project: FileSystemItem = .folder(name: "project", contents: [
    .file(name: "main.swift", size: 200),
    .folder(name: "Sources", contents: [
        .file(name: "app.swift", size: 500),
        .file(name: "utils.swift", size: 150)
    ]),
    .file(name: "README.md", size: 80)
])
print(totalSize(project))
printTree(project)

// E. Weather
enum Weather {
    case sunny(tempC: Double)
    case rainy(tempC: Double, mmPrecipitation: Double)
    case snowy(tempC: Double, cmSnow: Double)
    case cloudy
}
let week: [Weather] = [
    .sunny(tempC: 25.0),
    .rainy(tempC: 15.0, mmPrecipitation: 12.5),
    .cloudy,
    .snowy(tempC: -5.0, cmSnow: 20.0),
    .rainy(tempC: 10.0, mmPrecipitation: 3.0),
    .sunny(tempC: 28.0),
    .rainy(tempC: 8.0, mmPrecipitation: 15.0)
]
for case let .rainy(tempC, mm) in week where mm > 10 {
    print("rainy: \(tempC)°C, \(mm) мм")
}
if case let .sunny(tempC) = week[0] { print("Первый день солнечный: \(tempC)°C") }

// F. describe
func describe(_ value: Any) -> String {
    switch value {
    case is Int: return "Целое число"case let s as String where s.isEmpty: return "Пустая строка"
    case let s as String: return "Строка: \(s)"
    case let arr as [Int] where arr.count > 3: return "Большой массив Int (\(arr.count) элементов)"
    default: return "Неизвестный тип"
    }
}
print(describe(42))
print(describe(""))
print(describe("hello"))
print(describe([1, 2, 3, 4, 5]))

//  G. SessionState
enum SessionState {
    case guest
    case loggedIn(username: String)
    case banned(reason: String)
}
struct UserSession {
    var state: SessionState = .guest

    mutating func login(username: String) {
        guard case .guest = state else { print("Ошибка: нельзя войти в состоянии \(state)"); return }
        state = .loggedIn(username: username)
        print("Вход: \(username)")
    }
    mutating func ban(reason: String) {
        guard case .loggedIn = state else { print("Ошибка: бан невозможен"); return }
        state = .banned(reason: reason)
        print("Бан: \(reason)")
    }
    mutating func logout() {
        guard case .loggedIn = state else { print("Ошибка: выход невозможен"); return }
        state = .guest
        print("Выход")
    }
    mutating func appeal() {
        guard case .banned = state else { print("Ошибка: апелляция недоступна"); return }
        state = .guest
        print("Апелляция принята")
    }
}
var session = UserSession()
session.login(username: "alice")
session.ban(reason: "спам")
session.login(username: "bob")
session.appeal()
session.login(username: "alice")

// H. Expression
indirect enum Expression {
    case number(Double)
    case addition(Expression, Expression)
    case subtraction(Expression, Expression)
    case multiplication(Expression, Expression)
    case division(Expression, Expression)
}
func evaluate(_ expr: Expression) -> Double {
    switch expr {
    case .number(let v): return v
    case .addition(let l, let r): return evaluate(l) + evaluate(r)
    case .subtraction(let l, let r): return evaluate(l) - evaluate(r)
    case .multiplication(let l, let r): return evaluate(l) * evaluate(r)
    case .division(let l, let r):
        let d = evaluate(r)
        return d == 0 ? .infinity : evaluate(l) / d
    }
}
func describeExpr(_ expr: Expression) -> String {
    switch expr {
    case .number(let v): return "\(v)"
    case .addition(let l, let r): return "(\(describeExpr(l)) + \(describeExpr(r)))"
    case .subtraction(let l, let r): return "(\(describeExpr(l)) - \(describeExpr(r)))"
    case .multiplication(let l, let r): return "(\(describeExpr(l)) * \(describeExpr(r)))"
    case .division(let l, let r): return "(\(describeExpr(l)) / \(describeExpr(r)))"
    }
}
let expr: Expression = .multiplication(
    .addition(.number(3), .number(5)),
    .number(2)
)
print(evaluate(expr))
print(describeExpr(expr))