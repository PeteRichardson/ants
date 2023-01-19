//
//  Ant.swift
//  ants
//
//  Created by Peter Richardson on 1/13/23.
//

import SpriteKit


class Ant : SKSpriteNode {
    
    static var antCount = 0;
    
    static let defaultColor = SKColor.black
    static let defaultSize = CGSize(width: 15, height: 15)
    static let defaultDirection = 0.0
    static let defaultMass : CGFloat = 1.0
    
    var direction : CGFloat = Ant.defaultDirection
    let moveSpeed = 1.0
    var sizeChangedBy : CGSize? = nil
    let id = antCount
    var birthSound : String?
    var eatSound : String? = "bite.m4a"

    init(texture: SKTexture? = nil,
         color: SKColor? =  Ant.defaultColor,
         size: CGSize? = Ant.defaultSize,
         position: CGPoint? = nil,
         direction: CGFloat? = nil) {
 
        super.init(texture: SKTexture.init(imageNamed: "ant"),
                   color: color ?? Ant.defaultColor,
                   size: size ?? Ant.defaultSize)
        Ant.antCount += 1
//        self.id = Ant.antCount
        self.position = position ?? CGPoint(x: CGFloat.random(in: 0...screenSize.width),
                                            y: CGFloat.random(in: 0...screenSize.height))
        self.direction = direction ?? CGFloat.random(in: -.pi ... .pi)
        self.speed = 0.5
        let idStr = String(format: "%03d", self.id)
        self.name = "\((color == .red) ? "Red__" : "Black")_\(idStr)"
        let physRect = CGSize(width: self.size.width * 0.7, height: self.size.height * 0.7)
        self.physicsBody = SKPhysicsBody(rectangleOf: physRect)
        self.physicsBody!.isDynamic = true
        self.physicsBody!.contactTestBitMask = self.physicsBody!.collisionBitMask
        
        self.colorBlendFactor = 1.0  // Needed to apply .color to texture
        
        if let s = self.birthSound {
            self.run(SKAction.playSoundFileNamed(s, waitForCompletion: false))
        }
        self.run(SKAction.rotate(toAngle: self.direction, duration: 0.0))
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("SKSpriteNode.init?() was called but it's not implemented!")
    }
    
    // base Ants don't turn, move or grow
    func nextDirection() -> CGFloat { return self.direction }
    func nextPosition() -> CGPoint { return self.position }
    func nextSize() -> CGSize { return self.size }
    
    func grow() {
        if let delta = self.sizeChangedBy {
            self.size.width += delta.width / 5
            self.size.height += delta.height / 5
            self.sizeChangedBy = nil
        }
    }
    
    func turn() {
        self.direction = self.nextDirection()
        self.run(SKAction.rotate(toAngle: (.pi * 1.5) + self.direction, duration: 0.01, shortestUnitArc: true))
    }
    
    func move() {
        self.position = self.nextPosition()
    }
    
    func update() {
        turn()
        move()
        grow()
    }
    
    func destroy() {
        Ant.antCount -= 1
        print("(ants remaining = \(Ant.antCount))")
        self.removeFromParent()
    }
    
    func isEnemy(_ otherAnt : Ant) -> Bool {
        return self.color != otherAnt.color
    }
    
    func fight(_ otherAnt: Ant) {
        let (bigger, smaller) = self.size.width > otherAnt.size.width ? (self, otherAnt) : (otherAnt, self)
        print(" \(bigger) eats \(smaller)! ", terminator: "")
        if let s = self.eatSound {
            self.run(SKAction.playSoundFileNamed(s, waitForCompletion: false))
        }
        bigger.sizeChangedBy = smaller.size
        smaller.destroy()
    }
    
    func reactToCollision(body: SKNode?) {
        // only react to ant collisions, for now
        guard let otherAnt = body as? Ant else { return }
        
        if isEnemy(otherAnt) {
            fight(otherAnt)
         }
    }
    
    override var description : String {
        let sizeStr = String(format: "%.1f", self.size.width)
       return "\(self.name!) (\(sizeStr))"
    }
}
