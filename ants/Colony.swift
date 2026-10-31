//
//  Colony.swift
//  ants
//
//  Created by Peter Richardson on 1/20/23.
//

import SpriteKit

class Colony: SKSpriteNode {
    static let defaultPopulation = 100

    /// - Parameters:
    ///   - colorBlendFactor: How strongly `color` tints the anthill texture. At 1.0 SpriteKit
    ///     multiplies the texture by `color`, so a black tint hides all detail and a red tint
    ///     keeps only the low-contrast red channel. Use a lower value for those colors.
    ///   - alpha: Opacity of the anthill over the background.
    init(name: String, population: Int = Colony.defaultPopulation, color: SKColor = .red,
         colorBlendFactor: CGFloat = 1.0, alpha: CGFloat = 0.5) {
        let texture = SKTexture(imageNamed: "anthill")
        super.init(texture: texture, color: color, size: texture.size())

        setScale(0.5)
        self.alpha = alpha
        self.name = name
        self.colorBlendFactor = colorBlendFactor

        // TODO: Spread this out over time.
        for _ in 0..<population {
            addAnt(namePrefix: name)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    /// Updates every ant, forwarding the scene's food grid so bites mutate the same
    /// storage the food layer draws.
    func update(deltaTime: TimeInterval, food: inout FoodWorld) {
        for case let ant as Ant in children {
            ant.update(deltaTime: deltaTime, food: &food)
        }
    }

    private func addAnt(namePrefix: String) {
        let height = Int.random(in: 26...42)
        let ant = RandomAnt(color: color,
                            size: CGSize(width: Int(Double(height) * 1.34), height: height),
                            namePrefix: namePrefix)
        addChild(ant)
    }
}
