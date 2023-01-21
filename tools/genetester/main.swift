//
//  main.swift
//  genetester
//
//  Created by Peter Richardson on 1/20/23.
//

import Foundation

let screenSize = CGSize(width: 1024, height: 768)

func generation(_ mother: Ant, _ father: Ant) -> Ant {
    print(mother.genes)
    print(father.genes)
    let child = Ant(parent1: mother, parent2: father)
    print(child.genes)
    print("----------------------------------------------------------")
    return child
}

var a1 = Ant()
var a2 = Ant()

for _ in 1...100 {
    let child = generation(a1, a2)
    a1 = child
    a2 = Ant()
}
