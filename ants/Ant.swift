//
//  Ant.swift
//  ants
//
//  Created by Peter Richardson on 1/13/23.
//

import Cocoa
import SpriteKit

class Ant: SKSpriteNode {
    init(color: NSColor, size: CGSize) {
        let texture = SKTexture.init(imageNamed: "ant")
        super.init(texture: texture, color: color, size: size)
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody!.linearDamping = CGFloat(0.2)
        self.physicsBody!.angularDamping = CGFloat(5.0)
        self.physicsBody!.mass = 1
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func move() {
        if let vel = self.physicsBody?.velocity {
            if vel.length() < 30.0 {
                let dx = Double.random(in: -20.0...20.0)
                let dy = Double.random(in: -20.0...20.0)
                self.physicsBody!.applyImpulse(CGVector(dx: dx, dy: dy))
                let vel = self.physicsBody?.velocity
                if let foo = vel?.angleRadians() {
                    self.zRotation = foo - .pi/2
                }
            }
        }
    }
}
