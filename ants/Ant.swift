//
//  Ant.swift
//  ants
//
//  Created by Peter Richardson on 1/13/23.
//

import OSLog
import SpriteKit

class Ant: SKSpriteNode {

    static var antCount = 0
    static let antTexture = Ant.outlinedTexture(SKTexture(imageNamed: "smallant"))
    static let defaultColor = SKColor.black
    static let defaultSize = CGSize(width: 15, height: 10)
    static let defaultDirection = 0.0
    private static let log = Logger(subsystem: "com.peterichardson.ants", category: "fight")

    var genes = AntGenes()

    var direction = Ant.defaultDirection
    let moveSpeed = 2.0
    var health = 0.0
    var maxHealth = 0.0
    var attack = 0.0

    let id = antCount
    /// Colony prefix plus a three-digit number, for example `R042`. Also the node's `name`.
    private(set) var label = ""
    var eatSound: String? = "bite.m4a"

    /// - Parameter direction: Starting heading in radians. A new random value for each ant by
    ///   default.
    init(color: SKColor = Ant.defaultColor,
         size: CGSize = Ant.defaultSize,
         position: CGPoint = .zero,
         direction: Double = .random(in: -.pi ... .pi),
         namePrefix: String = "") {
        super.init(texture: Ant.antTexture, color: color, size: size)
        Ant.antCount += 1
        self.position = position
        self.direction = direction
        zRotation = direction
        speed = 0.5
        health = Double.random(in: 2...3) * size.width
        maxHealth = health
        attack = Double(Int(size.width) + Int.random(in: -5...5))
        label = namePrefix + id.formatted(.number.precision(.integerLength(3...)).grouping(.never))
        name = label

        let body = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 0.7, height: size.height * 0.7))
        body.isDynamic = true
        body.contactTestBitMask = body.collisionBitMask
        physicsBody = body

        colorBlendFactor = 1.0  // Needed to apply .color to texture
    }

    convenience init(parent1: Ant, parent2: Ant) {
        self.init()
        genes = AntGenes(parent1: parent1, parent2: parent2)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
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

    // Base ants don't turn, move, or grow.
    func nextDirection() -> Double { direction }
    func nextPosition() -> CGPoint { position }

    func turn() {
        direction = nextDirection()
        zRotation = direction
    }

    func move() {
        position = nextPosition()
    }

    func update(_ currentTime: TimeInterval) {
        alpha = health / maxHealth
        turn()
        move()
    }

    func destroy() {
        Ant.antCount -= 1
        removeFromParent()
    }

    func isEnemy(_ otherAnt: Ant) -> Bool {
        color != otherAnt.color
    }

    func fight(_ otherAnt: Ant) {
        let (bigger, smaller) = size.width > otherAnt.size.width ? (self, otherAnt) : (otherAnt, self)
        if let eatSound {
            run(SKAction.playSoundFileNamed(eatSound, waitForCompletion: false))
        }
        Self.log.debug("\(smaller.status, privacy: .public) vs \(bigger.status, privacy: .public): \(smaller.label, privacy: .public) -\(bigger.attack) | \(bigger.label, privacy: .public) -\(smaller.attack)")
        bigger.health -= smaller.attack
        smaller.health -= bigger.attack
        for ant in [smaller, bigger] where ant.health <= 0 {
            Self.log.debug("\(ant.status, privacy: .public) dies! ants remaining = \(Ant.antCount)")
            ant.destroy()
        }
    }

    func reactToCollision(body: SKNode?) {
        // Only react to ant collisions, for now.
        guard let otherAnt = body as? Ant else { return }

        if isEnemy(otherAnt) {
            fight(otherAnt)
        }
    }

    /// Name and current health for the fight log, e.g. `R042[71]`.
    ///
    /// Not an override of `description`: that `NSObject` property is nonisolated, and the
    /// ant's state is isolated to the main actor.
    var status: String {
        "\(label)[\(health.formatted(.number.precision(.fractionLength(0)).grouping(.never)))]"
    }
}
