//
//  FoodWorld.swift
//  ants
//
//  Created by Peter Richardson on 10/31/26.
//

import CoreGraphics
import Foundation

/// The food supply on the board: a grid of cells, each holding an amount of food.
///
/// `FoodWorld` is plain data — no SpriteKit. It owns every food rule: where food starts,
/// how an empty location regrows after a delay, the cap per location, and spillover to
/// adjacent locations. The scene reads amounts and draws them; ants take food from it.
///
/// Locations are fixed for the run. `seedFood(count:avoiding:)` picks them at launch, and
/// food only ever grows back at locations that have held food before.
struct FoodWorld {

    /// The tunable numbers of the food system. Defaults are the first values from issue #1.
    struct Configuration {
        /// Side length of one grid cell, in points. 32 gives a 32 × 24 grid on the scene.
        var cellSize: CGFloat = 32
        /// How many locations to seed at launch.
        var seedCount: Int = 12
        /// Food in a location at launch, below the cap so it grows on.
        var seedAmount: Double = 60
        /// Most food one location can hold.
        var capacity: Double = 100
        /// Seconds an emptied location waits before its regrowth starts.
        var regrowDelay: TimeInterval = 20
        /// Food one producing location adds per second.
        var regrowPace: Double = 4
    }

    let columns: Int
    let rows: Int
    private let configuration: Configuration
    private var amounts: [Double]
    /// Cells that have held food at some point. Only these grow; other cells are bare sand.
    private var producing: [Bool]
    /// Per-cell countdown for emptied locations. Zero means the location grows freely.
    private var delayRemaining: [TimeInterval]

    init(boardSize: CGSize, configuration: Configuration = Configuration()) {
        self.columns = Int(boardSize.width / configuration.cellSize)
        self.rows = Int(boardSize.height / configuration.cellSize)
        self.configuration = configuration
        self.amounts = [Double](repeating: 0, count: columns * rows)
        self.producing = [Bool](repeating: false, count: columns * rows)
        self.delayRemaining = [TimeInterval](repeating: 0, count: columns * rows)
    }

    /// Marks the given cells as food locations and sets their amount. Locations stay fixed
    /// for the run; food only ever grows back at these cells.
    mutating func placeFood(at cells: [Int], amount: Double) {
        for cell in cells where amounts.indices.contains(cell) {
            amounts[cell] = amount
            producing[cell] = true
        }
    }

    /// Food in a cell. Out-of-range cells read as empty.
    func amount(at cell: Int) -> Double {
        amounts.indices.contains(cell) ? amounts[cell] : 0
    }

    /// Food in the cell under `point`. Points off the grid read as empty.
    func amount(at point: CGPoint) -> Double {
        guard let cell = cellIndex(containing: point) else { return 0 }
        return amount(at: cell)
    }

    /// Randomly places `count` food locations at launch, at the configured seed amount.
    ///
    /// Uses rejection sampling, the same idea as `GameScene.openPosition(for:awayFrom:)`:
    /// a candidate is rejected when its center lies inside one of the `keepOut` rects
    /// (anthills) or when the cell already holds food. If no open candidate turns up
    /// within 100 attempts per remaining location, the seed stops early with what it has.
    mutating func seedFood(count: Int, avoiding keepOut: [CGRect], maxAttemptsPerLocation: Int = 100) {
        var placed = 0
        var attempts = 0
        let attemptLimit = maxAttemptsPerLocation * Swift.max(count, 1)
        while placed < count && attempts < attemptLimit {
            attempts += 1
            let cell = Int.random(in: 0..<(columns * rows))
            let center = CGPoint(x: (CGFloat(cell % columns) + 0.5) * configuration.cellSize,
                                y: (CGFloat(cell / columns) + 0.5) * configuration.cellSize)
            guard !keepOut.contains(where: { $0.contains(center) }) else { continue }
            guard amounts[cell] == 0 else { continue }
            placeFood(at: [cell], amount: configuration.seedAmount)
            placed += 1
        }
    }

    /// Removes up to `amount` food from a location and returns what was actually taken.
    /// Emptying a location starts its regrow delay.
    mutating func take(from cell: Int, upTo amount: Double) -> Double {
        guard amounts.indices.contains(cell) else { return 0 }
        let taken = min(amounts[cell], max(0, amount))
        amounts[cell] -= taken
        if amounts[cell] == 0 {
            delayRemaining[cell] = configuration.regrowDelay
        }
        return taken
    }

    /// Advances the food world by `deltaTime` seconds.
    ///
    /// Every producing location grows at the configured pace. A location at its cap sends
    /// that tick's growth to one adjacent location at random, the 8 directions around it.
    /// The receiving location becomes a producer itself, clamped at its own cap. If every
    /// adjacent location is full, the growth is lost until space becomes available.
    /// Cells that receive food start growing on the next update, not the current one.
    mutating func update(deltaTime: TimeInterval) {
        let producingNow = producing
        for cell in amounts.indices where producingNow[cell] {
            if amounts[cell] == 0 {
                guard delayRemaining[cell] == 0 else {
                    delayRemaining[cell] = max(0, delayRemaining[cell] - deltaTime)
                    continue
                }
            }
            let gain = configuration.regrowPace * deltaTime
            if amounts[cell] >= configuration.capacity {
                if let target = adjacentCells(of: cell).filter({ amounts[$0] < configuration.capacity }).randomElement() {
                    amounts[target] = min(configuration.capacity, amounts[target] + gain)
                    producing[target] = true
                    delayRemaining[target] = 0
                }
                // No adjacent location has free space: this tick's growth is lost.
            } else {
                amounts[cell] = min(configuration.capacity, amounts[cell] + gain)
            }
        }
    }

    /// The 8 cells around `cell` (orthogonal and diagonal), clipped to the grid.
    private func adjacentCells(of cell: Int) -> [Int] {
        let row = cell / columns
        let column = cell % columns
        var result: [Int] = []
        for rowOffset in [-1, 0, 1] {
            for columnOffset in [-1, 0, 1] where rowOffset != 0 || columnOffset != 0 {
                let neighborRow = row + rowOffset
                let neighborColumn = column + columnOffset
                guard (0..<rows).contains(neighborRow), (0..<columns).contains(neighborColumn) else { continue }
                result.append(neighborRow * columns + neighborColumn)
            }
        }
        return result
    }

    /// Index of the cell containing `point`, or `nil` if the point is off the grid.
    func cellIndex(containing point: CGPoint) -> Int? {
        guard point.x >= 0, point.y >= 0 else { return nil }
        let column = Int(point.x / configuration.cellSize)
        let row = Int(point.y / configuration.cellSize)
        guard column < columns, row < rows else { return nil }
        return row * columns + column
    }
}
