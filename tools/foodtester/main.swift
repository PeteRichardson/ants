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

testGridGeometry()

print(failures == 0 ? "all tests passed" : "\(failures) test(s) failed")
exit(failures == 0 ? 0 : 1)
