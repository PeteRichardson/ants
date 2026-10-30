//
//  Ant.swift
//  ants
//
//  Created by Peter Richardson on 1/13/23.
//

import SpriteKit



class Ant : SKSpriteNode {

    static var antCount = 0;
    static let antTexture = Ant.outlinedTexture(SKTexture(imageNamed: "smallant"))
    static let defaultColor = SKColor.black
    static let defaultSize = CGSize(width: 15, height: 10)
    static let defaultDirection = 0.0
    var genes : AntGenes = AntGenes()

    var direction : CGFloat = Ant.defaultDirection
    let moveSpeed = 2.0
    var health : CGFloat = 0.0
    var maxHealth : CGFloat = 0.0
    var attack : CGFloat = 0.0

    let id = antCount
    /// Colony prefix plus a three-digit number, for example `R042`. Also the node's `name`.
    private(set) var label = ""
    var eatSound : String? = "bite.m4a"

    /// - Parameter direction: Starting heading in radians. A new random value for each ant by
    ///   default.
    init(color: SKColor = Ant.defaultColor,
         size: CGSize = Ant.defaultSize,
         position: CGPoint = .zero,
         direction: CGFloat = .random(in: -.pi ... .pi),
         namePrefix: String = "") {
        super.init(texture: Ant.antTexture, color: color, size: size)
        Ant.antCount += 1
        self.position = position
        self.direction = direction
        self.zRotation = direction
        self.speed = 0.5
        self.health = CGFloat.random(in: 2...3) * self.size.width
        self.maxHealth = self.health
        self.attack = CGFloat(Int(self.size.width) + Int.random(in: -5...5))
        self.label = namePrefix + String(format: "%03d", self.id)
        self.name = label

        let body = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 0.7, height: size.height * 0.7))
        body.isDynamic = true
        body.contactTestBitMask = body.collisionBitMask
        self.physicsBody = body

        self.colorBlendFactor = 1.0  // Needed to apply .color to texture
    }

    convenience init(parent1: Ant, parent2: Ant) {
        self.init()
        self.genes = AntGenes(parent1: parent1, parent2: parent2)
    }


    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("Ant.init?(coder:) was called but it's not implemented!")
    }

    /// Returns a copy of `texture` with a dark one-texel outline just inside the edge of the
    /// head, thorax, and abdomen. Legs and antennae (one texel wide) get no outline.
    ///
    /// The outline is part of the shared texture, so it costs nothing per frame. Tinting
    /// multiplies texels by the colony color, so the outline stays dark for every colony
    /// while the middle keeps the colony color, and it fades with the ant's alpha.
    /// Returns `texture` unchanged if the pixels can't be read.
    static func outlinedTexture(_ texture: SKTexture, outlineGray: UInt8 = 40) -> SKTexture {
        let image = texture.cgImage()
        let width = image.width, height = image.height
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
              let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8,
                                      bytesPerRow: width * 4, space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
              let data = context.data
        else { return texture }
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        let pixels = data.bindMemory(to: UInt8.self, capacity: width * height * 4)

        let neighbors = [(1, 0), (-1, 0), (0, 1), (0, -1)]
        func isSet(_ mask: [Bool], _ index: Int, _ offset: (Int, Int)) -> Bool {
            let x = index % width + offset.0, y = index / width + offset.1
            return x >= 0 && y >= 0 && x < width && y < height && mask[y * width + x]
        }

        let solid = (0..<width * height).map { pixels[$0 * 4 + 3] > 127 }
        // Morphological opening (erode, then dilate) with a plus-shaped kernel. It removes
        // the one-texel legs and antennae and keeps the thick body parts.
        let eroded = (0..<width * height).map { i in
            solid[i] && neighbors.allSatisfy { isSet(solid, i, $0) }
        }
        let body = (0..<width * height).map { i in
            solid[i] && (eroded[i] || neighbors.contains { isSet(eroded, i, $0) })
        }

        for i in 0..<width * height where body[i] && neighbors.contains(where: { !isSet(body, i, $0) }) {
            // Premultiplied alpha: scale the gray by the texel's alpha.
            let gray = UInt8(Int(outlineGray) * Int(pixels[i * 4 + 3]) / 255)
            pixels[i * 4] = gray
            pixels[i * 4 + 1] = gray
            pixels[i * 4 + 2] = gray
        }

        guard let outlined = context.makeImage() else { return texture }
        let result = SKTexture(cgImage: outlined)
        result.filteringMode = texture.filteringMode
        return result
    }

    // base Ants don't turn, move or grow
    func nextDirection() -> CGFloat { return self.direction }
    func nextPosition() -> CGPoint { return self.position }

    func turn() {
        self.direction = self.nextDirection()
        self.zRotation = self.direction
    }

    func move() {
        self.position = self.nextPosition()
    }

    func update(_ currentTime: TimeInterval) {
        self.alpha = self.health / self.maxHealth
        turn()
        move()
    }

    func destroy() {
        Ant.antCount -= 1
        self.removeFromParent()
    }

    func isEnemy(_ otherAnt : Ant) -> Bool {
        return self.color != otherAnt.color
    }

    func fight(_ otherAnt: Ant) {
        let (bigger, smaller) = self.size.width > otherAnt.size.width ? (self, otherAnt) : (otherAnt, self)
         if let s = self.eatSound {
            self.run(SKAction.playSoundFileNamed(s, waitForCompletion: false))
        }
        print(" \(smaller.status) vs \(bigger.status):  \(smaller.label) -\(bigger.attack) | \(bigger.label) -\(smaller.attack) ")
        bigger.health -= smaller.attack
        smaller.health -= bigger.attack
         if smaller.health <= 0 {
            print("\t\(smaller.status) dies!  ants remaining = \(Ant.antCount)")
            smaller.destroy()
        }
        if bigger.health <= 0 {
            print("\t\(bigger.status) dies!  ants remaining = \(Ant.antCount)")
            bigger.destroy()
        }
    }

    func reactToCollision(body: SKNode?) {
        // only react to ant collisions, for now
        guard let otherAnt = body as? Ant else { return }

        if isEnemy(otherAnt) {
            fight(otherAnt)
         }
    }

    /// Name and current health for the fight log, e.g. `R042[ 71]`.
    ///
    /// Not an override of `description`: that `NSObject` property is nonisolated, and the
    /// ant's state is isolated to the main actor.
    var status: String {
        let healthStr = String(format: "%3.0f", self.health)
       return "\(self.label)[\(healthStr)]"
    }
}
