//
//  RandomAnt.swift
//  ants
//
//  Created by Peter Richardson on 1/19/23.
//

import SpriteKit

class RandomAnt: Ant {
    static let turnNoise = NormalDistribution(mean: 0.0, deviation: 0.1)

    override func nextDirection() -> Double {
        var newDirection = direction + RandomAnt.turnNoise.next()
        if newDirection < 0 { newDirection += 2 * .pi }
        if newDirection > 2 * .pi { newDirection -= 2 * .pi }
        assert(newDirection.isFinite)
        return newDirection
    }

    override func nextPosition() -> CGPoint {
        CGPoint(x: position.x + moveSpeed * cos(direction),
                y: position.y + moveSpeed * sin(direction))
    }
}
