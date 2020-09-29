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

public class BattlespirePairPlayer: PairPlayer {
    public var first: Player
    public var second: Player
    public var numberRound: Int
    
    public var winner: Player {
        get {
            return first.score == numberRound ? first
                : (second.score == numberRound ? second : BattlespirePlayer(name: ""))
        }
    }
    
    public var endedRound: Bool {
        get {
            return first.score == numberRound || second.score == numberRound
        }
    }
    
    public init(first: Player, second: Player, numberRound: Int){
        self.first = first
        self.second = second
        self.numberRound = numberRound
    }
}

public class BattlespireTracker: BattlespireDelegate{
    public init(){}
    
    public func gameDidStartTurn(_ game: TurnbasedGame) {
        print("--- New Round N \(game.Rounds) ---")
    }
    
    public func playerDidStartTurn(_ player: Player) {
        print("\(player.name) rolls the dice")
    }
    
    public func gameDidEndTurn(_ game: TurnbasedGame) {
        print("--- End Round N \(game.Rounds) ---")
    }
}


public class Battlespire: DiceGame, MultiplayerGame, TurnbasedGame {
    public let name = "Battlespire"
    public var delegate: BattlespireDelegate?
    
    public init(){}
    
    public let dice = Dice(sides: 6, generator: LinearCongruentialGenerator())
    
    public var pairPlayers: [PairPlayer] = [BattlespirePairPlayer]()
    
    public func join (fplayer: Player, splayer: Player) {
        makePair(first: fplayer, second: splayer)
        delegate?.player(fplayer, didJoinTheGame: self)
        delegate?.player(splayer, didJoinTheGame: self)
    }
    
    private var numberOfRound = 1;
    
    public var Rounds: Int {
        get {
            return numberOfRound
        }
    }
    
    public func makePair(first: Player, second: Player) {
        pairPlayers.append(BattlespirePairPlayer(first: first, second: second, numberRound: numberOfRound))
    }
    
    public var hasEnded: Bool {
        get {
            if pairPlayers.count < 1 {
                return true;
            }
            else {
                return pairPlayers.count == 1 && pairPlayers.first!.endedRound
            }
        }
    }
    
    public func start(){
        for var p in pairPlayers {
            p.first.score = 0;
            p.first.hp = 7;
            p.second.score = 0;
            p.second.hp = 7;
        }
    
        delegate?.gameDidStart(self)
    }
    
    public func end() {
        let p = pairPlayers.first!
        delegate?.player(p.first.score == numberOfRound ? p.first : p.second, didTakeAction: .win)
        delegate?.gameDidEnd(self)
    }
    
    public func makeTurn(){
        while true {
            battleInRound()
            if self.hasEnded {
                break
            }

            let winners = pairPlayers.map({ $0.winner })
            delegate?.winners(winners, inRound: numberOfRound)

            numberOfRound+=1
                       
            var newPairs: [PairPlayer] = [BattlespirePairPlayer]()
            for i in stride(from: 0, to: pairPlayers.count, by: 2) {
                newPairs.append(BattlespirePairPlayer(first: winners[i], second: winners[i+1], numberRound: numberOfRound))
            }
            pairPlayers = newPairs
            
        }
    }
    
    public func battleInRound(){
        delegate?.gameDidStartTurn(self)
        var ord = true
        while pairPlayers.filter({x in !x.endedRound}).count > 0 {
            let pairs = pairPlayers.filter({p in !p.endedRound})
            for var p in pairs {
                delegate?.pairplayer(p, didStartedRound: numberOfRound)
                battleInPair(&p, order: ord)
            }
            ord = !ord
        }
        delegate?.gameDidEndTurn(self)
    }
    
    public func battleInPair(_ pair: inout PairPlayer, order ord: Bool){
        var (first, second) = ord ? (pair.first,pair.second) : (pair.second, pair.first)
        
        delegate?.playerDidStartTurn(first)
        let diceAttack = dice.roll()
        delegate?.game(self, didDiceRoll: diceAttack)
        delegate?.player(first, didTakeAction: .attack(attackPoints: diceAttack))
        
        delegate?.playerDidStartTurn(second)
        let diceDefend = dice.roll()
        delegate?.game(self, didDiceRoll: diceDefend)
        delegate?.player(second, didTakeAction: .defend(defendPoints: diceDefend))
        
        if diceAttack == diceDefend {
            delegate?.player(first, didTakeAction: .other(explanation: "missed!"))
        }
        else if diceAttack > diceDefend {
            let dif = diceAttack - diceDefend
            second.hp -= dif
            delegate?.player(first, didTakeAction: .success(strength: dif))
        }
        else if diceAttack < diceDefend {
            delegate?.player(second, didTakeAction: .other(explanation: "successfully defended himself!"))
            let dif = diceDefend - diceAttack - 2
            if dif > 0 {
                second.hp += dif
                delegate?.player(second, didTakeAction: .heal(healPoints: dif))
            }
        }
        
        if second.hp < 1 {
            first.score = numberOfRound
            delegate?.pairplayer(first, winnerInPairRound: numberOfRound)
            delegate?.pairplayer(pair, didEndedRound: numberOfRound)
        }
        
    }
}
