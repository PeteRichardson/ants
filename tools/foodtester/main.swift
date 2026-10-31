//
//  main.swift
//  foodtester
//
//  Created by Peter Richardson on 10/31/26.
//

import Foundation

var failures = 0

@MainActor
func check(_ condition: Bool, _ name: String) {
    if condition {
        print("PASS \(name)")
    } else {
        print("FAIL \(name)")
        failures += 1
    }
}

@MainActor
func testGridGeometry() {
    let world = FoodWorld(boardSize: CGSize(width: 1024, height: 768),
                         configuration: FoodWorld.Configuration())
    check(world.columns == 32, "grid has 32 columns for a 1024-point board with 32-point cells")
    check(world.rows == 24, "grid has 24 rows for a 768-point board with 32-point cells")
    check(world.cellIndex(containing: CGPoint(x: 0, y: 0)) == 0,
          "bottom-left point is cell 0")
    check(world.cellIndex(containing: CGPoint(x: 1023.5, y: 767.5)) == 32 * 24 - 1,
          "top-right point is the last cell")
    check(world.cellIndex(containing: CGPoint(x: 2000, y: 0)) == nil,
          "point off the board has no cell")
}

@MainActor
func testPlaceFoodAndAmount() {
    var world = FoodWorld(boardSize: CGSize(width: 1024, height: 768),
                         configuration: FoodWorld.Configuration())
    world.placeFood(at: [5], amount: 60)
    check(world.amount(at: 5) == 60, "a placed location holds the placed amount")
    check(world.amount(at: 6) == 0, "an untouched location holds no food")
    // Cell 5 is row 0, column 5; its center is (5 × 32 + 16, 16) = (176, 16).
    check(world.amount(at: CGPoint(x: 176, y: 16)) == 60,
          "reading amount at a point returns the food in the cell under it")
    check(world.amount(at: CGPoint(x: 2000, y: 2000)) == 0,
          "reading amount off the board returns no food")
}

@MainActor
func testTakeAndRegrowDelay() {
    var world = FoodWorld(boardSize: CGSize(width: 1024, height: 768),
                         configuration: FoodWorld.Configuration())
    world.placeFood(at: [40], amount: 60)
    check(world.take(from: 40, upTo: 30) == 30, "take returns up to the requested amount")
    check(world.amount(at: 40) == 30, "a partial take leaves the rest in place")
    check(world.take(from: 40, upTo: 100) == 30, "take returns only what is there")
    check(world.amount(at: 40) == 0, "taking everything empties the location")
    check(world.take(from: 41, upTo: 10) == 0, "take from an empty location returns nothing")

    // Default regrow delay is 20 seconds.
    world.update(deltaTime: 10)
    check(world.amount(at: 40) == 0, "an emptied location stays empty while the delay runs")
    world.update(deltaTime: 10)
    check(world.amount(at: 40) == 0, "the location is still empty the moment the delay ends")
    world.update(deltaTime: 1)
    check(world.amount(at: 40) == 4,
          "after the delay, regrowth starts at the pace (4 food per second)")
}

@MainActor
func testCapacityCap() {
    var world = FoodWorld(boardSize: CGSize(width: 1024, height: 768),
                         configuration: FoodWorld.Configuration())
    world.placeFood(at: [100], amount: 95)
    world.update(deltaTime: 1)
    check(world.amount(at: 100) == 99, "a location grows by the pace each second")
    world.update(deltaTime: 1)
    check(world.amount(at: 100) == 100, "growth stops at the cap")
    world.update(deltaTime: 5)
    check(world.amount(at: 100) == 100, "a full location never grows past the cap")
}

/// The 8 cells around row 12, column 16 (cell 400) of a 32 × 24 grid — a center cell
/// is far enough from every edge that all its diagonals exist.
func neighborCells(of center: Int, columns: Int) -> [Int] {
    let row = center / columns
    let column = center % columns
    var result: [Int] = []
    for rowOffset in [-1, 0, 1] {
        for columnOffset in [-1, 0, 1] where rowOffset != 0 || columnOffset != 0 {
            result.append((row + rowOffset) * columns + (column + columnOffset))
        }
    }
    return result
}

@MainActor
func testSpilloverToAdjacentLocations() {
    let center = 12 * 32 + 16
    let neighbors = neighborCells(of: center, columns: 32)
    check(neighbors.count == 8, "the center cell has 8 neighbors")

    var world = FoodWorld(boardSize: CGSize(width: 1024, height: 768),
                         configuration: FoodWorld.Configuration())
    world.placeFood(at: [center], amount: 100)
    world.update(deltaTime: 1)
    check(world.amount(at: center) == 100, "a full location keeps its stored food")
    let received = neighbors.filter { world.amount(at: $0) > 0 }
    check(received.count == 1, "a full location puts its extra growth on one adjacent location")
    if let target = received.first {
        check(world.amount(at: target) == 4, "the adjacent location receives that tick's growth")
    } else {
        check(false, "the adjacent location receives that tick's growth")
    }

    // Every direction, including diagonals, must be reachable by the random choice.
    var seenDirections: Set<Int> = []
    for _ in 0..<400 {
        var fresh = FoodWorld(boardSize: CGSize(width: 1024, height: 768),
                             configuration: FoodWorld.Configuration())
        fresh.placeFood(at: [center], amount: 100)
        fresh.update(deltaTime: 1)
        if let target = neighborCells(of: center, columns: 32).first(where: { fresh.amount(at: $0) > 0 }) {
            seenDirections.insert(target)
        }
    }
    check(seenDirections.count == 8,
          "all 8 adjacent directions, including diagonals, can receive spillover")

    // A location that received spillover regrows on its own once emptied.
    var spreading = FoodWorld(boardSize: CGSize(width: 1024, height: 768),
                             configuration: FoodWorld.Configuration())
    spreading.placeFood(at: [center], amount: 100)
    spreading.update(deltaTime: 1)
    guard let receiver = neighborCells(of: center, columns: 32).first(where: { spreading.amount(at: $0) > 0 }) else {
        check(false, "a location that received spillover becomes a producing location")
        return
    }
    _ = spreading.take(from: center, upTo: 100)
    _ = spreading.take(from: receiver, upTo: 100)
    spreading.update(deltaTime: 20)
    spreading.update(deltaTime: 1)
    check(spreading.amount(at: receiver) == 4,
          "a location that received spillover becomes a producing location")
}

/// Total food on the whole board.
func sumAll(_ world: FoodWorld) -> Double {
    (0..<(world.columns * world.rows)).reduce(0) { $0 + world.amount(at: $1) }
}

/// A 3 × 3 block of cells centered on row 12, column 16 of a 32 × 24 grid.
func blockCells(around center: Int, columns: Int) -> [Int] {
    let row = center / columns
    let column = center % columns
    var result: [Int] = []
    for rowOffset in [-1, 0, 1] {
        for columnOffset in [-1, 0, 1] {
            result.append((row + rowOffset) * columns + (column + columnOffset))
        }
    }
    return result
}

@MainActor
func testSurroundedBlockHaltsAndResumes() {
    let center = 12 * 32 + 16
    let block = blockCells(around: center, columns: 32)
    let cellBelowCenter = center + 32

    var world = FoodWorld(boardSize: CGSize(width: 1024, height: 768),
                         configuration: FoodWorld.Configuration())
    world.placeFood(at: block, amount: 100)

    // Tick 1: the center is fully surrounded by full locations, so its 4 of growth is
    // lost. The 8 block cells on the edge each send their 4 to bare ring cells (none
    // reaches the cap), so the board gains exactly 8 × 4 = 32.
    world.update(deltaTime: 1)
    check(abs(sumAll(world) - 932) < 0.001,
          "a fully surrounded location loses its growth; the 8 edge cells spill 32")
    check(world.amount(at: center) == 100, "the surrounded location stays at the cap")
    let allWithinCap = (0..<(world.columns * world.rows)).allSatisfy { world.amount(at: $0) <= 100 }
    check(allWithinCap, "no cell exceeds the cap")

    // Open space on one block cell next to the center. That cell is itself an edge cell,
    // so tick 2 gains: center resumes (+4), the opened cell grows itself (+4), the other
    // 7 edge cells still spill (7 × 4), and each ring cell that holds food now grows
    // itself (+4 each).
    let ringCellsWithFood = (0..<(world.columns * world.rows))
        .filter { world.amount(at: $0) > 0 && !block.contains($0) }
    _ = world.take(from: cellBelowCenter, upTo: 50)
    world.update(deltaTime: 1)
    let expected = 932 - 50 + 4 + 4 + 28 + 4 * Double(ringCellsWithFood.count)
    check(abs(sumAll(world) - expected) < 0.001,
          "the surrounded location starts growing again once space becomes available")
}

@MainActor
func testSeedFoodAvoidsKeepOut() {
    // Keep out everything except the last 4 columns (x ≥ 896). All seeded locations must
    // fall in that band.
    let keepOut = CGRect(x: 0, y: 0, width: 896, height: 768)
    var world = FoodWorld(boardSize: CGSize(width: 1024, height: 768),
                         configuration: FoodWorld.Configuration())
    world.seedFood(count: 10, avoiding: [keepOut])
    let seededCells = (0..<(world.columns * world.rows)).filter { world.amount(at: $0) > 0 }
    check(seededCells.count == 10, "seeding places the requested number of locations")
    check(seededCells.allSatisfy { $0 % world.columns >= 28 },
          "no seeded location sits inside a keep-out area")
    check(seededCells.allSatisfy { world.amount(at: $0) == 60 },
          "seeded locations start at the seed amount")
}

testGridGeometry()
testPlaceFoodAndAmount()
testTakeAndRegrowDelay()
testCapacityCap()
testSpilloverToAdjacentLocations()
testSurroundedBlockHaltsAndResumes()
testSeedFoodAvoidsKeepOut()

print(failures == 0 ? "all tests passed" : "\(failures) test(s) failed")
exit(failures == 0 ? 0 : 1)
