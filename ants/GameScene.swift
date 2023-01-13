import SpriteKit
import Foundation



var ants : [Ant?] = []

class GameScene: SKScene {
    
    override func didMove(to view: SKView) {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    }

    override func sceneDidLoad() {
        self.backgroundColor = .white
        physicsWorld.gravity = CGVector (dx: 0.0, dy: 0.0)
        
        let numAnts = 75
        for _ in 1...numAnts {
            let s = Int.random(in: 15...20)
            let ant = Ant(color: .red, size: CGSize(width: s, height: s))
            ant.position = CGPoint(x: 400, y:300)
            addChild(ant)
            ants.insert(ant, at: 0)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        for ant in ants {
            ant?.move()
        }
     }
}
