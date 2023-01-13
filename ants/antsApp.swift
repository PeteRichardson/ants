//
//  antsApp.swift
//  ants
//
//  Created by Peter Richardson on 1/12/23.
//

import SwiftUI

let screenSize = CGSize(width: 1024, height: 768)

@main
struct antsApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: screenSize.width,
                       maxWidth: screenSize.width,
                       minHeight: screenSize.height,
                       maxHeight: screenSize.height)
        }
    }
}
