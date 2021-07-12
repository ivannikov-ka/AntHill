//
//  UserInterface.swift
//  AntWorldStructs
//
//  Created by Кирилл Иванников on 04.07.2021.
//

import SwiftUI

struct UserInterface: View {
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        ZStack {
            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text("Веток: \(AntHill.shared.sticksContainer.objects.count)")
                        Text("Еды: \(AntHill.shared.smallFoodContainer.objects.count)")
                        Text("Муравьев: \(AntHill.shared.antsContainer.ants.count)")
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.field.isActive.toggle()
                    }, label: {
                        Image(systemName: viewModel.field.isActive ? "pause.fill" : "play.fill")
                    })
                }
                
                Spacer()
            }
            
            if viewModel.field.antHill.antsContainer.ants.first(where: {$0.isSeek == false}) == nil {
                Text("Все заражены")
                    .font(.title)
            }
        }
        .padding()
    }
}
