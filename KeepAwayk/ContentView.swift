//
//  ContentView.swift
//  KeepAwayk
//
//  Created by Justin Doan on 7/7/24.
//

import SwiftUI

struct ContentView: View {
    @State private var mouseMovements = false
    @State private var leftClicks = false
    @State private var rightClicks = false
    @State private var keyboardButtons = false
    @State private var isRunning = false
    @State private var interval: Double = 5.0
    @State private var timer: Timer?
    
    var body: some View {
        VStack {
            Toggle("Mouse Movements", isOn: $mouseMovements)
                .toggleStyle(CheckboxToggleStyle())
            
            Toggle("Left Clicks", isOn: $leftClicks)
                .toggleStyle(CheckboxToggleStyle())
            
            Toggle("Right Clicks", isOn: $rightClicks)
                .toggleStyle(CheckboxToggleStyle())
            
            Toggle("Keyboard Buttons", isOn: $keyboardButtons)
                .toggleStyle(CheckboxToggleStyle())
            
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
                Text(isRunning ? "Stop" : "Start")
                    .font(.title)
                    .padding()
                    .foregroundColor(.white)
                    
            }.background(isRunning ? Color.red : Color.green).cornerRadius(10)
        }
        .padding()
    }
    
    private func startActions() {
        performAction()
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            if !isRunning {
                timer.invalidate()
                return
            }
            performAction()
        }
    }
    
    private func performAction() {
        print("Action performed at \(Date())")
        // Add your action logic here
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

