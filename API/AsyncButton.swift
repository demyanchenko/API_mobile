//
//  AsyncButton.swift
//  API
//
//  Created by Александр Демьянченко on 15.03.2026.
//
// Статья:
// https://dev.to/0xwdg/building-an-asynchronous-button-in-swiftui-2nmd

import SwiftUI

/// A button that performs an asynchronous task when tapped.
struct AsyncButton<Label: View>: View {
    /// The asynchronous action to perform when the button is tapped.
    var action: () async throws -> Void

    /// The label of the button.
    @ViewBuilder
    var label: () -> Label

    /// Whether the task is currently being performed.
    @State
    private var isPerformingTask = false

    /// The error message to display if the task fails.
    @State
    private var errorMessage: String?

    /// Whether to show the alert.
    @State
    private var showAlert = false

    var body: some View {
        Button(action: {
            // When the button is tapped, we are performing a task
            isPerformingTask = true

            // Perform the task asynchronously
            Task {
                do {
                    // Perform the asynchronous task
                    try await action()

                    // If the task completes successfully, clear the error message (if any)
                    errorMessage = nil
                } catch {
                    // If the task fails, display the error message
                    errorMessage = error.localizedDescription
                }

                // After the task is completed, we are no longer performing a task
                isPerformingTask = false

                // Show the alert if there is an error
                showAlert = errorMessage != nil
            }
        }) {
            HStack {
                // Show a loading indicator while the task is in progress
                if isPerformingTask {
                    // Use a mini progress view
                    ProgressView()
                        .controlSize(.mini)
                }

                // Show the button label
                label()
            }
        }
        // Disable the button while the task is in progress
        .disabled(isPerformingTask)
        // Show an alert with the error message if the task fails
        .alert(isPresented: $showAlert) {
            // Display an alert with the error message
            Alert(
                title: Text("Error"),
                message: Text(errorMessage ?? ""),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

#Preview {
    @Previewable @StateObject  var productViewModel = ProductViewModel() 
//    AsyncButton(action: productViewModel.addItemSample) {Label("Get API", systemImage: "plus")}
}
