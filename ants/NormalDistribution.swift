//
//  NormalDistribution.swift
//  ants
//
//  Created by Peter Richardson on 1/16/23.
//

import Foundation

import GameplayKit

class NormalDistribution {
    private let randomSource: GKRandomSource
    let mean: CGFloat
    let deviation: CGFloat

    init(mean: CGFloat, deviation: CGFloat) {
        precondition(deviation >= 0)
        self.randomSource = GKRandomSource()
        self.mean = mean
        self.deviation = deviation
    }

    func nextFloat() -> CGFloat {
        guard deviation > 0 else { return mean }

        let x1 = randomSource.nextUniform() // a random number between 0 and 1
        let x2 = randomSource.nextUniform() // a random number between 0 and 1
        let z1 = CGFloat(sqrt(-2 * log(x1)) * cos(2 * Float.pi * x2)) // z1 is normally distributed

        // Convert z1 from the Standard Normal Distribution to our Normal Distribution
        return CGFloat(z1 * deviation + mean)
    }
}
