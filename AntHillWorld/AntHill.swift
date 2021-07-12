//
//  AntHill.swift
//  AntWorldStructs
//
//  Created by Кирилл Иванников on 04.07.2021.
//

import SwiftUI

class AntHill {
    static var shared = AntHill()
    
    var antsContainer = AntsContiner()
    var sticksContainer = SmallObjectContainer()
    var smallFoodContainer = SmallObjectContainer()
    
    let position = CGPoint(x: UIScreen.width / 2, y: UIScreen.height / 2)
    
    func tick() {
        antsContainer.tick()
    }
    
    init() {
        antsContainer.ants.append(Ant(antType: .mother))
    }
    
    //Calculated values
    var isReadyForMother: Bool {
        sticksContainer.objects.count >= 15
    }
    
    var radius: CGFloat {
        let real = sqrt(CGFloat(sticksContainer.objects.count) / CGFloat.pi) * 9
        return real > 10 ? real : 10
    }
    
    var allEntityList: [GameInstance] {
        return antsContainer.ants
    }
    
    var allSmallObjectList: [SmallObject] {
        return sticksContainer.objects
            + smallFoodContainer.objects
    }
    
    //Methods
    func birthAnts() {
        guard let mother = AntHill.shared.antsContainer.ants.first(where: {$0.antType == .mother}) else {
            return
        }
        var birthCount = 0
        if antsContainer.ants.count == 1 {
            birthCount = 1
        } else {
            birthCount = Int.random(in: 0...smallFoodContainer.objects.count / 5)
            smallFoodContainer.objects.removeLast(birthCount * 5)
        }
        
        for _ in 0..<birthCount {
            antsContainer.ants.append(Ant(position: mother.position.random(in: 15)))
        }
    }
    
    func putSmallObject(object: SmallObject) {
        switch object.type {
        case .food:
            smallFoodContainer.addObject(object: object)
        case .stick:
            sticksContainer.addObject(object: object)
        }
    }
}
