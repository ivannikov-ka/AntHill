//
//  Field.swift
//  AntWorldStructs
//
//  Created by Кирилл Иванников on 04.07.2021.
//

import SwiftUI

class Field: ObservableObject {
    static var shared = Field()
    
    @Published var isActive = true
    
    var antHill = AntHill.shared
    
    var sticksContainer = SmallObjectContainer()
    var smallFoodContainer = SmallObjectContainer()
    var antMarksContainer = AntMarkContainer()
    
    init() {
        startTickRate()
    }
    
    func startTickRate() {
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [self] timer in
            if isActive {
                antHill.tick()
                sticksContainer.tick()
                smallFoodContainer.tick()
                antMarksContainer.tick()
                
                spawnObjects()
                
                objectWillChange.send()
            }
        }
    }
    
    //Calculated values
    var allEntityList: [GameInstance] {
        return antHill.allEntityList
    }
    
    var allSmallObjectList: [SmallObject] {
        return antHill.allSmallObjectList
            + sticksContainer.objects
            + smallFoodContainer.objects
    }
    
    var allSmallObjectListFieldContainered: [SmallObject] {
        return sticksContainer.objects
            + smallFoodContainer.objects
    }
    
    var allAntMarksList: [AntMark] {
        return antMarksContainer.antMarks
    }
    
    //Methods
    func removeSmallObject(id: UUID) {
        sticksContainer.objects.removeAll(where: {$0.id == id})
        smallFoodContainer.objects.removeAll(where: {$0.id == id})
    }
    
    func putSmallObject(object: SmallObject) {
        switch object.type {
        case .food:
            break
        case .stick:
            sticksContainer.addObject(object: object)
        }
    }
    
    func leaveAntMark(type: AntMarkType, position: CGPoint) {
        let antMark = AntMark(position: position, type: type)
        antMarksContainer.addObject(antMark: antMark)
    }
    
    func clearAntMark(type: AntMarkType, position: CGPoint) {
        antMarksContainer.antMarks.removeAll(where: { $0.position.distance(to: position) < 20 })
    }
    
    func spawnObjects() {
        if Double.random(in: 0..<1) < 0.09 {
            let randomPosition = CGPoint(x: CGFloat.random(in: 0..<UIScreen.width), y: CGFloat.random(in: 0..<UIScreen.height))
            sticksContainer.addObject(position: randomPosition, type: .stick)
        }
        
        if Double.random(in: 0..<1) < 0.01 {
            let randomPosition = CGPoint(x: CGFloat.random(in: 0..<UIScreen.width), y: CGFloat.random(in: 0..<UIScreen.height))
            smallFoodContainer.addObject(position: randomPosition, type: .food)
        }
        
        if Double.random(in: 0..<1) < 0.006 {
            let randomPosition = CGPoint(x: CGFloat.random(in: 20..<UIScreen.width - 20), y: CGFloat.random(in: 20..<UIScreen.height - 20))
            
            for _ in 0..<Int.random(in: 10..<20) {
                smallFoodContainer.addObject(position: randomPosition.random(in: 10), type: .food)
            }
        }
    }
}
