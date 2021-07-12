//
//  AntMark.swift
//  AntWorldStructs
//
//  Created by Кирилл Иванников on 06.07.2021.
//

import SwiftUI

enum AntMarkType: CaseIterable {
    case food
    case danger
    
    static func rand() -> AntMarkType {
        return AntMarkType.allCases.randomElement()!
    }
}

class AntMark: GameInstance, Identifiable {
    //GameInstance
    var id = UUID()
    var position: CGPoint
    var liveTime: Int = 0
    var image = Image(systemName: "circlebadge.fill")
    
    func tick() {
        liveTime += 1
    }
    
    //Extensions
    var type: AntMarkType
    
    init(position: CGPoint = .zero, type: AntMarkType = AntMarkType.rand()) {
        self.position = position
        self.type = type
    }
    
    //Calculated values
    var color: Color {
        switch type {
        case .food:
            return .blue
        case .danger:
            return .purple
        }
    }
}

class AntMarkContainer {
    @Published var antMarks: [AntMark] = []
    
    func tick() {
        antMarks.forEach { antMark in
            antMark.tick()
            
            if antMark.liveTime > 150 {
                antMarks.removeAll(where: {$0.id == antMark.id})
            }
        }
    }
    
    func addObject(antMark: AntMark) {
        let antMark = AntMark(position: antMark.position, type: antMark.type)
        antMarks.append(antMark)
    }
}
