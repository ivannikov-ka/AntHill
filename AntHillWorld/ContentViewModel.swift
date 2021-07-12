//
//  ContentViewModel.swift
//  AntWorldStructs
//
//  Created by Кирилл Иванников on 04.07.2021.
//

import Foundation
import Combine

class ContentViewModel: ObservableObject {
    var subscriptions = Set<AnyCancellable>()

    var field = Field.shared
    
    init() {
        field.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
        }
        .store(in: &subscriptions)
    }
}
