//
//  Colony.swift
//  ants
//
//  Created by Peter Richardson on 1/20/23.
//

import SpriteKit

class Colony: SKSpriteNode {
    static let defaultPopulation = 100
    
    init(name: String, population: Int? = Colony.defaultPopulation, location: CGPoint? = nil , color: SKColor = .red) {
        let texture : SKTexture? = SKTexture(imageNamed: "anthill")
        guard let texture else { fatalError("Can't load anthill texture.  Check asset catalog")}
        super.init(texture: texture, color: color,
                   size: texture.size())
        
        self.position = location ?? CGPoint(x: CGFloat.random(in: 0...screenSize.width), y: CGFloat.random(in: 0...screenSize.height))
        self.setScale(0.5)
        self.alpha = 0.5
        self.name = name
        self.colorBlendFactor = 1.0
        
        // TODO:  spread this out over time.
        for _ in 1...population! {
            addAnt()
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
    
    func addAnt() {
        let s : Int = Int.random(in: 26...42)
        let color = self.color
        let position = CGPoint(x:0.0, y:0.0)
        
        let ant = RandomAnt(color: color,
                      size: CGSize(width: s, height: Int(Double(s) * 1.34)),
                      position: position)
        ant.name = self.name! + "_\(ant.name!)"
        addChild(ant)
    }

}
