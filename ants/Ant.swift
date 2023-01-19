//
//  Ant.swift
//  ants
//
//  Created by Peter Richardson on 1/13/23.
//

import SpriteKit


class Ant : SKSpriteNode {
    
    static var antCount = 0;
    static var randomFloats = NormalDistribution(mean: 0.0, deviation: 0.1)

    static let defaultColor = SKColor.black
    static let defaultSize = CGSize(width: 15, height: 15)
    static let defaultDirection = 0.0
    static let defaultMass : CGFloat = 1.0
    
    var direction : CGFloat = Ant.defaultDirection
    let moveSpeed = 1.0
    var sizeChanged : Bool = false
    let id = antCount

    init(texture: SKTexture? = nil,
         color: SKColor? =  Ant.defaultColor,
         size: CGSize? = Ant.defaultSize,
         position: CGPoint? = nil,
         direction: CGFloat? = nil) {
 
        super.init(texture: SKTexture.init(imageNamed: "ant"),
                   color: color ?? Ant.defaultColor,
                   size: size ?? Ant.defaultSize)
        Ant.antCount += 1
        self.position = position ?? CGPoint(x: CGFloat.random(in: 0...screenSize.width),
                                            y: CGFloat.random(in: 0...screenSize.height))
        self.direction = direction ?? CGFloat.random(in: -.pi ... .pi)
        self.speed = 0.5
        self.name = (color == .red) ? "red" : "black"
        let physRect = CGSize(width: self.size.width * 0.7, height: self.size.height * 0.7)
        self.physicsBody = SKPhysicsBody(rectangleOf: physRect)
        self.physicsBody!.isDynamic = true
        self.physicsBody!.contactTestBitMask = self.physicsBody!.collisionBitMask
        
        self.colorBlendFactor = 1.0  // Needed to apply .color to texture
        
            // self.run(SKAction.playSoundFileNamed("bite.m4a", waitForCompletion: false))
        self.run(SKAction.rotate(toAngle: self.direction, duration: 0.0))
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("SKSpriteNode.init?() was called but it's not implemented!")
    }
    
    func nextDirection() -> CGFloat {
        var newDirection = self.direction + Ant.randomFloats.nextFloat()
        if newDirection < 0       { newDirection += 2 * .pi }
        if newDirection > 2 * .pi { newDirection -= 2 * .pi }
        assert(newDirection != CGFloat.infinity)
        assert(!newDirection.isNaN)
        return newDirection
    }
    
    func nextPosition() -> CGPoint {
        let newX = self.position.x + self.moveSpeed * Darwin.cos(self.direction)
        let newY = self.position.y + self.moveSpeed * Darwin.sin(self.direction)
        assert(!newX.isNaN && !newY.isNaN)
        return CGPoint(x: newX, y: newY)
    }
    
    private func turn() {
        self.direction = self.nextDirection()
        self.run(SKAction.rotate(toAngle: (.pi * 1.5) + self.direction, duration: 0.01, shortestUnitArc: true))
    }
    
    func move() {
        self.position = self.nextPosition()
    }

    func update() {
        turn()
        move()
        if self.sizeChanged {
            self.run(SKAction.playSoundFileNamed("bite.m4a", waitForCompletion: false))

            self.size.width *= 1.1
            self.size.height *= 1.1
            self.sizeChanged = false
        }
    }
}
