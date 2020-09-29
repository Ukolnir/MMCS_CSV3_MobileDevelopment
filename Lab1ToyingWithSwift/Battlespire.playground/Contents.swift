import Foundation

let game = Battlespire()

game.delegate = BattlespireTracker()

for (fname,sname) in ["Viren" : "Nil", "Den" : "Garret", "Karina" : "Sira", "Uko" : "Tess"]{
    let first = BattlespirePlayer(name: fname)
    let second = BattlespirePlayer(name: sname)
    game.join(fplayer: first, splayer: second)
}

game.play()
