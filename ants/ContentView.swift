//
//  ContentView.swift
//  ants
//
//  Created by Peter Richardson on 1/12/23.
//

import SwiftUI
import SpriteKit

let screenSize = CGSize(width: 1024, height: 768)

struct ContentView: View {

    var scene: SKScene {
        let scene = GameScene()
        scene.size = CGSize(width: screenSize.width, height: screenSize.height)
        scene.scaleMode = .aspectFit
        return scene
    }
    
    var body: some View {
        HStack {
            SpriteView(scene: scene)
                .frame(minWidth: screenSize.width,
                       maxWidth: screenSize.width,
                       minHeight: screenSize.height,
                       maxHeight: screenSize.height)
        }
    }
}

