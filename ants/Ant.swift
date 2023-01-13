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
}