//
//  SmallObject.swift
//  AntWorldStructs
//
//  Created by Кирилл Иванников on 04.07.2021.
//

import SwiftUI

enum SmallObjectType: CaseIterable {
    case food
    case stick
    
    static func rand() -> SmallObjectType {
        return SmallObjectType.allCases.randomElement()!
    }
}

class SmallObject: GameInstance, Identifiable {
    //GameInstance
    var id = UUID()
    var position: CGPoint
    var liveTime: Int = 0
    var image: Image {
        switch type {
        case .food:
            return Image(systemName: "sun.min.fill")
        case .stick:
            return Image(systemName: "leaf.fill")
        }
    }
    
    func tick() {
        if isActive {
            liveTime += 1
        }
    }
    
    //Extensions
    var rotationAngle: CGFloat
    var isActive: Bool
    var type: SmallObjectType
    
    init(position: CGPoint = .zero, type: SmallObjectType = SmallObjectType.rand(), isActive: Bool = true) {
        self.position = position
        self.type = type
        self.isActive = isActive
        rotationAngle = CGFloat.random(in: 0..<360)
    }
    
    //Calculated values
    var opacity: Double {
        Double(1500 - liveTime) / 1500
    }
    
    var color: Color {
        switch type {
        case .food:
            return .red
        case .stick:
            return .green
        }
    }
}

class SmallObjectContainer {
    @Published var objects: [SmallObject] = []
    
    func tick() {
        objects.forEach { object in
            object.tick()
            
            if object.liveTime > 1500 && object.isActive {
                objects.removeAll(where: {$0.id == object.id})
            }
        }
    }
    
    func addObject(position: CGPoint, type: SmallObjectType) {
        objects.append(SmallObject(position: position, type: type))
    }
    
    func addObject(object: SmallObject) {
        let object = SmallObject(position: object.position, type: object.type, isActive: object.isActive)
        objects.append(object)
    }
}
