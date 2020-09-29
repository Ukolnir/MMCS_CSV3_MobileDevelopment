import Foundation

public protocol MultiplayerGame: Game {
    var pairPlayers: [PairPlayer] { get set }
    func join(fplayer: Player, splayer: Player)
}

// Delegates

public protocol MultiplayerGameDelegate: GameDelegate {
    func player(_ player: Player, didJoinTheGame game: MultiplayerGame)
    func player(_ player: Player, didTakeAction action: PlayerAction)
    func pairplayer(_ pairPlayer: PairPlayer, didStartedRound round: Int)
    func pairplayer(_ pairplayer: PairPlayer, didEndedRound round: Int)
    func pairplayer(_ player: Player, winnerInPairRound round: Int)
    func winners(_ players: [Player], inRound round: Int)
}
    
public protocol MultiplayerTurnbasedGameDelegate: TurnbasedGameDelegate, MultiplayerGameDelegate {
    func playerDidStartTurn(_ player: Player)
    func playerDidEndTurn(_ player: Player)
}

// Default Implementation

extension MultiplayerGameDelegate {
    public func player(_ player: Player, didJoinTheGame game: MultiplayerGame) {
        print("\(player.name) has joined the game")
    }
    
    public func player(_ player: Player, didTakeAction action: PlayerAction) {
        switch action {
        case .win:
            print("\(player.name) wins!")
        case let .attack(attackPoints):
            print("\(player.name) attacks with strenght \(attackPoints)")
        case let .defend(defendPoints):
            print("\(player.name) defends with strength \(defendPoints)")
        case let .heal(healPoints):
            print("\(player.name) heals with strength \(healPoints)")
        case let .other(explanation):
            print("\(player.name) \(explanation)")
        case let .success(strength):
            print("\(player.name) caused a loss with \(strength) points")
        }
    }
    
    public func pairplayer(_ pairplayer: PairPlayer, didStartedRound round: Int){
        print("Pair \(pairplayer.first.name) - \(pairplayer.second.name) has started battle")
    }
    
    public func pairplayer(_ pairplayer: PairPlayer, didEndedRound round: Int){
        print("Pair \(pairplayer.first.name) - \(pairplayer.second.name) has ended round \(round)")
    }
    
    public func pairplayer(_ player: Player, winnerInPairRound round: Int){
        print("Winner in round \(round) is \(player.name)")
    }
    
    public func winners(_ players: [Player], inRound round: Int){
        var str = "Winners in round N \(round): "
        for item in players {
            str += "\(item.name) "
        }
        print(str)
    }
}

extension MultiplayerTurnbasedGameDelegate {
    public func playerDidStartTurn(_ player: Player) {}
    public func playerDidEndTurn(_ player: Player) {}
}
