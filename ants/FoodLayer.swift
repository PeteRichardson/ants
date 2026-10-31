//
//  FoodLayer.swift
//  ants
//
//  Created by Peter Richardson on 10/31/26.
//

import SpriteKit

/// Draws the food supply: one node per grid cell that holds food.
///
/// `FoodLayer` only reads. It asks `FoodWorld` for the amount in each cell and keeps its
/// nodes in step with them — all amounts and food rules stay in `FoodWorld`. The scene
/// places the layer in the draw stack.
class FoodLayer: SKNode {

    /// Fresh green: darker and cooler than the pale sand, opposite in hue to the red and
    /// amber colonies, and light enough to stand out against the black ants.
    private static let foodColor = SKColor(srgbRed: 76 / 255, green: 160 / 255, blue: 76 / 255, alpha: 1)

    /// A cell with any food draws as a faint speck this fraction of full size; a full
    /// cell draws at full size and full clarity.
    private static let minScale: CGFloat = 0.35
    private static let minAlpha: CGFloat = 0.3

    /// The node drawn for each cell that holds food.
    private(set) var nodes: [Int: SKShapeNode] = [:]

    /// Brings the nodes in step with the world: every cell that holds food has a node,
    /// sized and faded by its amount; every cell without food has none.
    func sync(with world: FoodWorld) {
        for cell in 0..<(world.columns * world.rows) {
            let amount = world.amount(at: cell)
            guard amount > 0 else {
                nodes.removeValue(forKey: cell)?.removeFromParent()
                continue
            }
            let node = nodes[cell] ?? makeNode(for: cell, in: world)
            let fill = CGFloat(min(1, amount / world.capacity))
            let scale = Self.minScale + (1 - Self.minScale) * fill
            let alpha = Self.minAlpha + (1 - Self.minAlpha) * fill
            // SpriteKit dirties a node on every setter call, so write only when the
            // amount changed; capped and regrow-waiting cells draw identically frame to
            // frame.
            if node.xScale != scale { node.setScale(scale) }
            if node.alpha != alpha { node.alpha = alpha }
        }
    }

    private func makeNode(for cell: Int, in world: FoodWorld) -> SKShapeNode {
        let node = SKShapeNode(circleOfRadius: world.cellSize * 0.45)
        node.fillColor = Self.foodColor
        node.strokeColor = .clear
        node.position = world.center(of: cell)
        addChild(node)
        nodes[cell] = node
        return node
    }
}
