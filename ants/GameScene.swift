import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    override func didMove(to view: SKView) {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    }

    override func sceneDidLoad() {
        self.backgroundColor = .white
        physicsWorld.gravity = CGVector (dx: 0.0, dy: 0.0)
        physicsWorld.contactDelegate = self
        
        let numAnts = 200
        for i in 1...numAnts {
            let s : Int = Int.random(in: 13...21)
            let color : SKColor = (i % 2) != 0 ? .red : .black
            let position = CGPoint(x: CGFloat.random(in: 0...screenSize.width),
                                   y: CGFloat.random(in: 0...screenSize.height))
            
            let ant = RandomAnt(color: color,
                          size: CGSize(width: s, height: Int(Double(s) * 1.34)),
                          position: position)
            
            addChild(ant)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        for node in self.children {
            if let ant = node as? Ant {
                ant.update()
            }
        }
     }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if let ant = contact.bodyA.node as? Ant {
            ant.reactToCollision(body: contact.bodyB.node)
        }
    }
    
}
