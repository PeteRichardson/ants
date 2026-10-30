//
//  NormalDistribution.swift
//  ants
//
//  Created by Peter Richardson on 1/16/23.
//

import Foundation

/// Samples a normal (Gaussian) distribution with the Box–Muller transform.
///
/// A value type with no stored generator, so it is `Sendable` and safe to share as a
/// `static let`. Pass a generator to `next(using:)` for reproducible sequences.
struct NormalDistribution: Sendable {
    let mean: Double
    let deviation: Double

    init(mean: Double, deviation: Double) {
        precondition(deviation >= 0)
        self.mean = mean
        self.deviation = deviation
    }

    /// Returns the next sample, using `generator` for the uniform inputs.
    func next(using generator: inout some RandomNumberGenerator) -> Double {
        guard deviation > 0 else { return mean }

        // u1 starts above zero so that log(u1) is always finite.
        let u1 = Double.random(in: Double.leastNonzeroMagnitude..<1, using: &generator)
        let u2 = Double.random(in: 0..<1, using: &generator)
        let z = (-2 * log(u1)).squareRoot() * cos(2 * .pi * u2)   // standard normal
        return z * deviation + mean
    }

    /// Returns the next sample, using the system random number generator.
    func next() -> Double {
        var generator = SystemRandomNumberGenerator()
        return next(using: &generator)
    }
}
