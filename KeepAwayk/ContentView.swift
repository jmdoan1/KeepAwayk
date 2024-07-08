//
//  ContentView.swift
//  KeepAwayk
//
//  Created by Justin Doan on 7/7/24.
//

import SwiftUI

struct ContentView: View {
    private let options = [
        "Mouse movements",
        "Left clicks",
        "Right clicks",
        "Keyboard actions"
    ];
    @State private var states: [String: Bool]
    
    init() {
        _states = State(initialValue: Dictionary(uniqueKeysWithValues: options.map { ($0, true) }))
    }
    
    @State private var isRunning = false
    @State private var interval: Double = 5.0
    
    var body: some View {
        VStack {
            ForEach(options, id: \.self) { key in
                Toggle(key, isOn: Binding<Bool>(
                    get: { states[key] ?? false },
                    set: { states[key] = $0 }
                ))
                .toggleStyle(CheckboxToggleStyle())
            }
            
            HStack {
                Text("Do something every")
                TextField("", value: $interval, format: .number)
                    .frame(width: 50)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Stepper("seconds", value: $interval)
            }
            
            Button(action: {
                isRunning.toggle()
                if isRunning {
                    startActions()
                }
            }) {
                Text(isRunning ? "Stop (⌘ + Y)" : "Start (⌘ + Y)")
                    .font(.title)
                    .padding()
                    .foregroundColor(.white)
            }
            .background(isRunning ? Color.red : Color.green).cornerRadius(10)
            .keyboardShortcut("y", modifiers: .command)
        }
        .padding()
    }
    
    private func startActions() {
        performAction()
        
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            if !isRunning {
                timer.invalidate()
                return
            }
            performAction()
        }
    }
    
    private func performAction() {
        let activeActions = states.keys.filter { states[$0] == true }
        if activeActions.isEmpty {
            print("No active actions")
        } else {
            if let randomAction = activeActions.randomElement() {
                print("Random active action: \(randomAction)")
            }
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

