//
//  FoodWorld.swift
//  ants
//
//  Created by Peter Richardson on 10/31/26.
//

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

    init(boardSize: CGSize, configuration: Configuration = Configuration()) {
        self.columns = Int(boardSize.width / configuration.cellSize)
        self.rows = Int(boardSize.height / configuration.cellSize)
        self.configuration = configuration
        self.amounts = [Double](repeating: 0, count: columns * rows)
    }

    /// Marks the given cells as food locations and sets their amount. Locations stay fixed
    /// for the run; food only ever grows back at these cells.
    mutating func placeFood(at cells: [Int], amount: Double) {
        for cell in cells where amounts.indices.contains(cell) {
            amounts[cell] = amount
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

    /// Index of the cell containing `point`, or `nil` if the point is off the grid.
    func cellIndex(containing point: CGPoint) -> Int? {
        guard point.x >= 0, point.y >= 0 else { return nil }
        let column = Int(point.x / configuration.cellSize)
        let row = Int(point.y / configuration.cellSize)
        guard column < columns, row < rows else { return nil }
        return row * columns + column
    }
}
