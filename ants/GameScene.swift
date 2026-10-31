import SpriteKit

// SpriteKit calls the contact delegate on the main thread during physics simulation, so the
// conformance is isolated to the main actor like the rest of the scene.
class GameScene: SKScene, @MainActor SKPhysicsContactDelegate {

    /// Pale sand. Light and low in saturation, so that red, black, and amber ants all keep
    /// contrast against it without the ground pulling attention from the ants. A darker or
    /// more yellow sand makes amber ants hard to see.
    static let sandColor = SKColor(srgbRed: 228 / 255, green: 218 / 255, blue: 196 / 255, alpha: 1)

    private var isSetUp = false

    /// The food grid and the layer that draws it. Both are created in `didMove(to:)`,
    /// which is the first point that knows `size`, or neither is.
    private var food: (world: FoodWorld, layer: FoodLayer)?
    /// Scene frame clock. Food rules run on real elapsed seconds.
    private var lastUpdateTime: TimeInterval?

    /// Builds the world the first time the scene is presented. Setup runs here, not in
    /// `sceneDidLoad`, because the scene's `size` is set by then.
    override func didMove(to view: SKView) {
        guard !isSetUp else { return }
        isSetUp = true

        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        backgroundColor = GameScene.sandColor
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

        if let sand = makeSandTexture(size: size) {
            let ground = SKSpriteNode(texture: sand)
            ground.position = CGPoint(x: size.width / 2, y: size.height / 2)
            ground.zPosition = -1
            addChild(ground)
        }

        // Red, black, and amber are real ant colors that stay distinct from each other and
        // from the sand, even when ants fade as they lose health.
        // Blend and alpha values are tuned per color so that each anthill keeps visible
        // texture detail and a clear hole.
        let amber = SKColor(srgbRed: 215 / 255, green: 140 / 255, blue: 20 / 255, alpha: 1)
        let colonySpecs: [(name: String, color: SKColor, blend: CGFloat, alpha: CGFloat)] = [
            ("R", .red,   0.7, 0.8),
            ("B", .black, 0.6, 0.8),
            ("A", amber,  1.0, 0.8),
        ]
        var colonies: [Colony] = []
        for spec in colonySpecs {
            let colony = Colony(name: spec.name, color: spec.color,
                                colorBlendFactor: spec.blend, alpha: spec.alpha)
            colony.position = openPosition(for: colony, awayFrom: colonies)
            addChild(colony)
            colonies.append(colony)
        }

        let foodConfiguration = FoodWorld.Configuration()
        var world = FoodWorld(boardSize: size, configuration: foodConfiguration)
        world.seedFood(count: foodConfiguration.seedCount, avoiding: colonies.map(\.frame))
        let layer = FoodLayer()
        // Food lies between the ground (−1) and the ants (default 0): on the sand, but
        // not covering ants that walk over it.
        layer.zPosition = -0.5
        addChild(layer)
        food = (world: world, layer: layer)
        layer.sync(with: world)
    }

    /// Draws a sand texture: `sandColor` with scattered faint light and dark grains.
    ///
    /// Grains are grouped into a few shade levels so each level is one batched fill,
    /// which keeps generation fast at startup.
    private func makeSandTexture(size: CGSize) -> SKTexture? {
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
              let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height),
                                      bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        else { return nil }

        context.setFillColor(GameScene.sandColor.cgColor)
        context.fill(CGRect(origin: .zero, size: size))

        // Each level: (gray, alpha). White grains lighten, black grains darken.
        let shades: [(gray: CGFloat, alpha: CGFloat)] = [
            (1, 0.06), (1, 0.12), (1, 0.18),
            (0, 0.06), (0, 0.12), (0, 0.18),
        ]
        let grainsPerShade = Int(size.width * size.height) / 40
        for shade in shades {
            let grains = (0..<grainsPerShade).map { _ in
                CGRect(x: CGFloat.random(in: 0..<size.width),
                       y: CGFloat.random(in: 0..<size.height),
                       width: CGFloat.random(in: 1...2.5),
                       height: CGFloat.random(in: 1...2.5))
            }
            context.setFillColor(CGColor(gray: shade.gray, alpha: shade.alpha))
            context.fill(grains)
        }

        guard let image = context.makeImage() else { return nil }
        return SKTexture(cgImage: image)
    }

    /// Returns a random position that keeps the whole anthill in the scene and is at least
    /// two anthill-widths from every other colony.
    ///
    /// Uses rejection sampling. If no candidate fits after `maxAttempts`, returns the candidate
    /// that is farthest from its nearest neighbor.
    private func openPosition(for colony: Colony, awayFrom others: [Colony],
                              maxAttempts: Int = 100) -> CGPoint {
        let halfWidth = colony.frame.width / 2
        let halfHeight = colony.frame.height / 2
        let minDistance = colony.frame.width * 2

        var best = CGPoint.zero
        var bestDistance = -CGFloat.infinity
        for _ in 0..<maxAttempts {
            let candidate = CGPoint(x: CGFloat.random(in: halfWidth...(size.width - halfWidth)),
                                    y: CGFloat.random(in: halfHeight...(size.height - halfHeight)))
            let nearest = others.map { hypot($0.position.x - candidate.x, $0.position.y - candidate.y) }
                                .min() ?? .infinity
            if nearest >= minDistance { return candidate }
            if nearest > bestDistance {
                best = candidate
                bestDistance = nearest
            }
        }
        return best
    }

    override func update(_ currentTime: TimeInterval) {
        let deltaTime = currentTime - (lastUpdateTime ?? currentTime)
        lastUpdateTime = currentTime

        // Mutate the stored world directly; a local `var` copy would duplicate its
        // backing arrays on every frame.
        food?.world.update(deltaTime: deltaTime)
        if let food {
            food.layer.sync(with: food.world)
        }

        for case let colony as Colony in children {
            colony.update(currentTime)
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        if let ant = contact.bodyA.node as? Ant {
            ant.reactToCollision(body: contact.bodyB.node)
        }
    }
}
