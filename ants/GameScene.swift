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
            let s = Int.random(in: 13...21)
            let color : SKColor = (i % 2) != 0 ? .red : .black
            let position = CGPoint(x: CGFloat.random(in: 0...screenSize.width),
                                   y: CGFloat.random(in: 0...screenSize.height))
            
            let ant = Ant(color: color,
                          size: CGSize(width: s, height: s),
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
        if let AName = contact.bodyA.node?.name, let BName = contact.bodyB.node?.name {
            if (AName != BName) {
                collisionBetween(ant1: contact.bodyA.node!, ant2: contact.bodyB.node!)
            }
        }
    }
    
    func collisionBetween(ant1: SKNode, ant2: SKNode) {
        if let a1 = ant1 as? Ant,
           let a2 = ant2 as? Ant  {
            if a1.size.width > a2.size.width {
                //print("\(a1.name!) eats \(a2.name!)!")
                a1.size.width += a2.size.width / 4
                a1.size.height += a2.size.height / 4
                destroy(ant: ant2)
            } else if a2.size.width > a1.size.width {
                //print("\(a2.name!) eats \(a1.name!)!")
                a2.size.width += a1.size.width / 4
                a2.size.height += a1.size.height / 4
                destroy(ant: ant1)
            }
        }
    }

    func destroy(ant: SKNode) {
        ant.removeFromParent()
    }
}
