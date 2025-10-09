//
//  CreateView.swift
//  CarDet
//
//  Created by BenjiLoya on 09.10.2025.
//

import SwiftUI

struct CreateView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                
            }
            .navigationTitle("Create View")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("close", systemImage: "xmark") {
                        dismiss()
                    }
                }
                
                ToolbarSpacer(.fixed, placement: .topBarTrailing)
                ToolbarItem(placement: .topBarTrailing) {
                    Button("add", systemImage: "checkmark") {
                        dismiss()
                    }
                }
                
//                ToolbarItem(placement: .bottomBar) {
//                    Button("New", systemImage: "plus") {
//
//                    }
//                }
            }
        }
    }
}

#Preview {
    CreateView()
}
