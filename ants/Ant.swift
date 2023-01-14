//
//  Ant.swift
//  ants
//
//  Created by Peter Richardson on 1/13/23.
//

import Cocoa
import SpriteKit

class Ant: SKSpriteNode {
    
    init(color: SKColor, size: CGSize) {
        let texture = SKTexture.init(imageNamed: "ant")
        super.init(texture: texture, color: color, size: size)
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.friction = 100.0
        self.physicsBody!.linearDamping = CGFloat(10)
//        self.physicsBody!.angularDamping = CGFloat(5.0)
        self.physicsBody!.isDynamic = true
        self.physicsBody!.mass = 1
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.run(SKAction.rotate(toAngle: self.direction, duration: 0.0))
    }
    
    var direction : CGFloat = 90.0
    
    func move() {
        self.direction = self.direction + CGFloat.random(in: -4...4)
        if self.direction > 360 {
            self.direction = self.direction - 360
        } else if self.direction < 0 {
            self.direction = self.direction + 360
        }
        
        let directionRadians = self.direction * .pi / -180
        self.run(SKAction.rotate(toAngle: directionRadians, duration: 0.0))
        let newLength = 25.0
        let dx = newLength * Darwin.cos(direction)
        let dy = newLength * Darwin.sin(direction)
        let newVec = CGVector(dx: dx, dy: dy)
        //print(dx)
        self.physicsBody!.applyImpulse(newVec)
    }
}
