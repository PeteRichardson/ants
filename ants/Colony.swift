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
        super.init(texture: texture, color: color,
                   size: texture.size())

        self.setScale(0.5)
        self.alpha = alpha
        self.name = name
        self.colorBlendFactor = colorBlendFactor

        // TODO:  spread this out over time.
        for _ in 0..<population {
            addAnt(namePrefix: name)
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("Colony.init?(coder:) was called but it's not implemented!")
    }

    func update(_ currentTime: TimeInterval) {
        for node in self.children {
            switch node {
            case let ant as Ant: ant.update(currentTime)
            default:
                break
            }
        }
    }

    private func addAnt(namePrefix: String) {
        let s : Int = Int.random(in: 26...42)
        let ant = RandomAnt(color: self.color,
                      size: CGSize(width: Int(Double(s) * 1.34), height: s),
                      namePrefix: namePrefix)
        addChild(ant)
    }

}
