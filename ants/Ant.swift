//
//  Ant.swift
//  ants
//
//  Created by Peter Richardson on 1/13/23.
//

import Cocoa
import SwiftUI
import SpriteKit

class Ant: SKSpriteNode {

    init(color: SKColor, size: CGSize) {
        let antfilename : String = (color == .red) ? "redant" : "blackant"
        let texture = SKTexture.init(imageNamed: antfilename)
        super.init(texture: texture, color: color, size: size)
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.friction = 100.0
        self.physicsBody!.linearDamping = CGFloat(10)
        self.physicsBody!.angularDamping = CGFloat(5.0)
        self.physicsBody!.isDynamic = true
        self.physicsBody!.mass = 1
        self.direction = CGFloat.random(in: -.pi ... .pi)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.run(SKAction.rotate(toAngle: self.direction, duration: 0.0))
    }
    
    var direction : CGFloat = 0.0
    
    private func turn(delta: CGFloat) {
        self.direction = self.direction + delta
        self.run(SKAction.rotate(toAngle: (.pi * 1.5) + self.direction, duration: 0.0))
    }
    
    func move() {
        let newLength = 1.0
        let dx = newLength * Darwin.cos(self.direction)
        let dy = newLength * Darwin.sin(self.direction)
        self.position = CGPoint(x: self.position.x + dx, y: self.position.y + dy)
    }
    
    func update() {
        let maxAngleDelta : CGFloat = .pi / 18.0  // randomly change direction by at most ±maxDeltaAngle... ≈ 10˚
        turn(delta: CGFloat.random(in: -maxAngleDelta ... maxAngleDelta))
        move()
    }
}
