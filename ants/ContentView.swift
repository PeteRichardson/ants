//
//  ContentView.swift
//  ants
//
//  Created by Peter Richardson on 1/12/23.
//

import SwiftUI
import SpriteKit


struct ContentView: View {
    var scene: SKScene {
        let scene = GameScene()
        scene.size = CGSize(width: screenSize.width, height: screenSize.height)
        scene.scaleMode = .aspectFit
       return scene
    }

    var body: some View {
        SpriteView(scene: scene)
    }
}

