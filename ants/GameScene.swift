import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    override func didMove(to view: SKView) {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    }

    override func sceneDidLoad() {
        self.backgroundColor = .white
        physicsWorld.gravity = CGVector (dx: 0.0, dy: 0.0)
        physicsWorld.contactDelegate = self
        
        var colonies: [Colony] = []
        for (name, color) in [("R", SKColor.red), ("B", .black), ("G", .green)] {
            let colony = Colony(name: name, color: color)
            colony.position = openPosition(for: colony, awayFrom: colonies)
            addChild(colony)
            colonies.append(colony)
        }
    }

    /// Returns a random position that keeps the whole anthill in the scene and is at least
    /// two anthill-widths from every other colony.
    ///
    /// Uses rejection sampling. If no candidate fits after `maxAttempts`, returns the candidate
    /// that is farthest from its nearest neighbor.
    /// Uses `screenSize` because the scene's `size` is not set yet when `sceneDidLoad` runs.
    private func openPosition(for colony: Colony, awayFrom others: [Colony],
                              maxAttempts: Int = 100) -> CGPoint {
        let halfWidth = colony.frame.width / 2
        let halfHeight = colony.frame.height / 2
        let minDistance = colony.frame.width * 2

        var best = CGPoint.zero
        var bestDistance = -CGFloat.infinity
        for _ in 0..<maxAttempts {
            let candidate = CGPoint(x: CGFloat.random(in: halfWidth...(screenSize.width - halfWidth)),
                                    y: CGFloat.random(in: halfHeight...(screenSize.height - halfHeight)))
            let nearest = others.map { hypot($0.position.x - candidate.x, $0.position.y - candidate.y) }
                                .min() ?? .infinity
            if nearest >= minDistance { return candidate }
            if nearest > bestDistance {
                best = candidate
                bestDistance = nearest
            }
        }
        return best
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
