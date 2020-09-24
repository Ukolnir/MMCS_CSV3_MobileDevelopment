import Foundation

public protocol Player {
    var name: String { get }
    var hp: Int { get set }
    var score: Int { get set }
}

public enum PlayerAction {
    case win
    case attack(attackPoints: Int)
    case defend(defendPoints: Int, strength: Int)
    case heal(healPoints: Int)
}
