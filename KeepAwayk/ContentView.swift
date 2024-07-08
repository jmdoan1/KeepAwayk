//
//  ContentView.swift
//  KeepAwayk
//
//  Created by Justin Doan on 7/7/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        VStack {
            ForEach(viewModel.options, id: \.self) { key in
                Toggle(key, isOn: Binding<Bool>(
                    get: { viewModel.states[key] ?? false },
                    set: { viewModel.states[key] = $0 }
                ))
                .toggleStyle(CheckboxToggleStyle())
            }
            
            HStack {
                Text("Do something every")
                TextField("", value: $viewModel.interval, format: .number)
                    .frame(width: 50)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Stepper("seconds", value: $viewModel.interval)
            }
            
            Button(action: {
                viewModel.toggleRunning()
            }) {
                Text(viewModel.isRunning ? "Stop (⌘ + Y)" : "Start (⌘ + Y)")
                    .font(.title)
                    .padding()
                    .foregroundColor(.white)
            }
            .background(viewModel.isRunning ? Color.red : Color.green).cornerRadius(10)
            .keyboardShortcut("y", modifiers: .command)
        }
        .padding()
        .onAppear {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                .resizable()
                .frame(width: 20, height: 20)
                .onTapGesture { configuration.isOn.toggle() }
        }
        .padding()
    }
}
