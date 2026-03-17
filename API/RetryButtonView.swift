//
//  RetryButtonView.swift
//  API
//
//  Created by Александр Демьянченко on 15.03.2026.
//

import SwiftUI
import Combine

class RefreshActionPerformer: ObservableObject {
    @Published private(set) var isPerforming = false

    func perform(_ action: RefreshAction) async {
        guard !isPerforming else { return }
        isPerforming = true
        await action()
        isPerforming = false
    }
}

struct RetryButton: View {
    var title: LocalizedStringKey = "Retry"
    
    @Environment(\.refresh) private var action
    @StateObject private var actionPerformer = RefreshActionPerformer()

    var body: some View {
//        if let action = action {
            Button(
                role: nil,
                action: {
                    Task {
                        await actionPerformer.perform(action!)
                    }
                },
                label: {
                    ZStack {
                        if actionPerformer.isPerforming {
                            Text(title).hidden()
                            ProgressView()
                        } else {
                            Text(title)
                        }
                    }
                }
            )
            .disabled(actionPerformer.isPerforming)
//        }
    }
}
