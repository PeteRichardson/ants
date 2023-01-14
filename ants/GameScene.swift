import SpriteKit
import Foundation



var ants : [Ant?] = []
var directionLabel : SKLabelNode? = nil

class GameScene: SKScene {
    
    override func didMove(to view: SKView) {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    }

    override func sceneDidLoad() {
        self.backgroundColor = .white
         physicsWorld.gravity = CGVector (dx: 0.0, dy: 0.0)
        
        let numAnts = 1
        for _ in 1...numAnts {
            let s = Int.random(in: 15...20)
            let ant = Ant(color: .red, size: CGSize(width: s, height: s))
            ant.position = CGPoint(x: CGFloat.random(in: 0...screenSize.width), y: CGFloat.random(in: 0...screenSize.height))
            addChild(ant)
            ants.insert(ant, at: 0)
        }
        
        directionLabel = SKLabelNode()
        directionLabel!.fontSize = 48
        directionLabel!.fontColor = SKColor.black
        directionLabel!.position = CGPoint(x: 512, y: 0)
        addChild(directionLabel!)
    }
    
    override func update(_ currentTime: TimeInterval) {
        for ant in ants {
            ant?.update()
        }
        directionLabel?.text = ants[0]!.direction.rounded().description
     }
}
