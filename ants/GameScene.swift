import SpriteKit
import Foundation


var ant1 : Ant? = nil

class GameScene: SKScene {
    
    override func didMove(to view: SKView) {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    }

    override func sceneDidLoad() {
        self.backgroundColor = .white
        physicsWorld.gravity = CGVector (dx: 0.0, dy: 0.0)
        
        ant1 = Ant(color: .red, size: CGSize(width: 20, height: 20))
        ant1!.position = CGPoint(x: 400, y:300)
        addChild(ant1!)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if let vel = ant1!.physicsBody?.velocity {
            if vel.length() < 30.0 {
                let dx = Double.random(in: -20.0...20.0)
                let dy = Double.random(in: -20.0...20.0)
                ant1!.physicsBody!.applyImpulse(CGVector(dx: dx, dy: dy))
                let vel = ant1!.physicsBody?.velocity
                if let foo = vel?.angleRadians() {
                    ant1!.zRotation = foo - .pi/2
                }
            }
        }
     }
}
