import Foundation

let game = Battlespire()

game.delegate = BattlespireTracker()

for name in ["Viren", "Nil"]{
    game.join(player: BattlespirePlayer(name: name))
}

game.play()
