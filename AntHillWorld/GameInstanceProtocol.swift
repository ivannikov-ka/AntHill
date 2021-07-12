//
//  GameInstanceProtocol.swift
//  AntWorldStructs
//
//  Created by Кирилл Иванников on 04.07.2021.
//

import SwiftUI

protocol GameInstance {
    var id: UUID { get }
    var position: CGPoint { get set }
    var liveTime: Int { get set }
    var image: Image { get }
    
    func tick()
}
