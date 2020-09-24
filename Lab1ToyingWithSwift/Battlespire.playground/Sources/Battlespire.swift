import Foundation

public protocol BattlespireDelegate: MultiplayerTurnbasedGameDelegate, DiceGameDelegate {}

public class BattlespirePlayer: Player {
    public let name: String
    public var hp: Int = 10
    public var score: Int = 0
    
    public init(name: String) {
        self.name = name
    }
}

public class BattlespireTracker: BattlespireDelegate{
    public init(){}
    
    public func gameDidStartTurn(_ game: TurnbasedGame) {
        print("--- New Round ---")
    }
    
    public func playerDidStartTurn(_ player: Player) {
        print("\(player.name) rolls the dice")
    }
}


public class Battlespire: DiceGame, MultiplayerGame, TurnbasedGame {
    public let name = "Battlespire"
    public var delegate: BattlespireDelegate?
    
    public init(){}
    
    public let dice = Dice(sides: 6, generator: LinearCongruentialGenerator())
    
    public var players: [Player] = [BattlespirePlayer]() // вот здесь можно добавлять других игроков
    
    public func join (player: Player) {
        players.append(player)
        delegate?.player(player, didJoinTheGame: self)
    }
    
    private var numberOfTurns = 0
    
    public var turns: Int {
        get { return numberOfTurns }
    }
    
    public var hasEnded: Bool {
        get {
            if players.count == 0 {
                return true;
            }
            else {
                return players.filter({p in p.score == 1}).count > 0
            }
        }
    }
    
    public func start(){
        for var p in players {
            p.score = 0;
            p.hp = 10;
        }
        delegate?.gameDidStart(self)
    }
    
    public func end() {
        delegate?.player(players.filter({p in p.score == 1}).first!, didTakeAction: .win)
        delegate?.gameDidEnd(self)
    }
    
    public func makeTurn(){
        numberOfTurns += 1
        delegate?.gameDidStartTurn(self)
        for var p in players {
            playerMakeTurn(&p)
            if self.hasEnded {
                break
            }
        }
        delegate?.gameDidEndTurn(self)
    }
    
    public func playerMakeTurn(_ player: inout Player){
        delegate?.playerDidStartTurn(player)
        let diceRoll = dice.roll()
        delegate?.game(self, didDiceRoll: diceRoll)
        
        if diceRoll == dice.sides {
            player.score = 1;
        }
        
        if numberOfTurns % 2 != 0 {
            delegate?.player(player, didTakeAction: .attack(attackPoints: diceRoll))
            
        }
        else {
            delegate?.player(player, didTakeAction: .defend(defendPoints: diceRoll, strength: 1))
        }
        
        delegate?.playerDidEndTurn(player)
    }
    
}
