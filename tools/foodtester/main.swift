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

testGridGeometry()
testPlaceFoodAndAmount()
testTakeAndRegrowDelay()

print(failures == 0 ? "all tests passed" : "\(failures) test(s) failed")
exit(failures == 0 ? 0 : 1)
