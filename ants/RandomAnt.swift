//
//  RandomAnt.swift
//  ants
//
//  Created by Peter Richardson on 1/19/23.
//

import Cocoa

class RandomAnt: Ant {
    static var randomFloats = NormalDistribution(mean: 0.0, deviation: 0.1)

    
    override func nextDirection() -> CGFloat {
        var newDirection = self.direction + RandomAnt.randomFloats.nextFloat()
        if newDirection < 0       { newDirection += 2 * .pi }
        if newDirection > 2 * .pi { newDirection -= 2 * .pi }
        assert(newDirection != CGFloat.infinity)
        assert(!newDirection.isNaN)
        return newDirection
    }
    
    override func nextPosition() -> CGPoint {
        let newX = self.position.x + self.moveSpeed * Darwin.cos(self.direction)
        let newY = self.position.y + self.moveSpeed * Darwin.sin(self.direction)
        assert(!newX.isNaN && !newY.isNaN)
        return CGPoint(x: newX, y: newY)
    }
    
    override func nextSize() -> CGSize {
        return CGSize(width: self.size.width * 1.1, height: self.size.height * 1.1)
    }

}
