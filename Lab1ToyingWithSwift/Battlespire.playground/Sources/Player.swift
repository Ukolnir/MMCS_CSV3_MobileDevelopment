import Foundation

public protocol Player {
    var name: String { get }
    var hp: Int { get set }
    var score: Int { get set }
}

public enum PlayerAction {
    case win
    case attack(attackPoints: Int)
    case defend(defendPoints: Int)
    case heal(healPoints: Int)
    case other(explanation: String)
    case success(strength: Int)
}

public protocol PairPlayer {
    var first : Player { get set }
    var second: Player { get set }
    var endedRound: Bool { get }
    var numberRound: Int { get set }
    var winner: Player { get }
}
