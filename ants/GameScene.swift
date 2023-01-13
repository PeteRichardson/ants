import SpriteKit


class GameScene: SKScene {
    override func didMove(to view: SKView) {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    }

    override func sceneDidLoad() {
        self.backgroundColor = .white

        physicsWorld.gravity = CGVector (dx: 0.0, dy: 0.0)
        let ant1 = Ant(color: .red, size: CGSize(width: 100, height:100))
        addChild(ant1)
        let box2 = SKSpriteNode(color: .blue, size: CGSize(width: 25, height: 35))
        box2.position = CGPoint(x:180,y:300)
        box2.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 25, height: 35))
        addChild(box2)
        box2.physicsBody!.linearDamping = CGFloat(0.2)
        box2.physicsBody!.applyImpulse( CGVector(dx: -1.0, dy: -1.0))
        box2.physicsBody!.mass = CGFloat(4.0)
        
        let box3 = SKSpriteNode(color: .blue, size: CGSize(width: 25, height: 35))
        box3.position = CGPoint(x:100,y:250)
        box3.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 25, height: 35))
        addChild(box3)
        box3.physicsBody!.linearDamping = CGFloat(0.2)
        box3.physicsBody!.applyImpulse( CGVector(dx: -1.0, dy: -1.0))
        box3.physicsBody!.mass = CGFloat(4.0)
    }
}
