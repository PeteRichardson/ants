import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    override func didMove(to view: SKView) {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    }

    override func sceneDidLoad() {
        self.backgroundColor = .white
        physicsWorld.gravity = CGVector (dx: 0.0, dy: 0.0)
        physicsWorld.contactDelegate = self
        
        let redColony = Colony(name: "R", color: .red)
        addChild(redColony)
        let blackColony = Colony(name: "G", color: .green)
        addChild(blackColony)
    }
    
    override func update(_ currentTime: TimeInterval) {
        for node in self.children {
            switch node {
            case let colony as Colony: colony.update(currentTime)
            default: break
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if let ant = contact.bodyA.node as? Ant {
            ant.reactToCollision(body: contact.bodyB.node)
        }
    }
    
}
