//
//  ContentView.swift
//  ants
//
//  Created by Peter Richardson on 1/12/23.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    private static let sceneSize = CGSize(width: 1024, height: 768)

    // Kept in @State so that SwiftUI re-renders don't create a new scene and restart the
    // simulation.
    @State private var scene: GameScene = {
        let scene = GameScene(size: ContentView.sceneSize)
        scene.scaleMode = .aspectFit
        return scene
    }()

    var body: some View {
        SpriteView(scene: scene)
            .frame(width: Self.sceneSize.width, height: Self.sceneSize.height)
    }
}
