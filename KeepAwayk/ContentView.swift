//
//  ContentView.swift
//  KeepAwayk
//
//  Created by Justin Doan on 7/7/24.
//

import SwiftUI
import AppKit
import CoreGraphics

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
    
    private func moveMouseRandomly() {
        let screenWidth = NSScreen.main?.frame.width ?? 1920
        let screenHeight = NSScreen.main?.frame.height ?? 1080
        
        let randomX = CGFloat(arc4random_uniform(UInt32(screenWidth)))
        let randomY = CGFloat(arc4random_uniform(UInt32(screenHeight)))
        
        let destination = CGPoint(x: randomX, y: randomY)
        moveMouseSmoothly(to: destination)
    }
    
    private func moveMouseSmoothly(to destination: CGPoint) {
        let currentLocation = getCurrentMouseLocation()
        let steps = 100
        let stepX = (destination.x - currentLocation.x) / CGFloat(steps)
        let stepY = (destination.y - currentLocation.y) / CGFloat(steps)

        for step in 0...steps {
            let newX = currentLocation.x + stepX * CGFloat(step)
            let newY = currentLocation.y + stepY * CGFloat(step)
            let newPosition = CGPoint(x: newX, y: newY)

            let event = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: newPosition, mouseButton: .left)
            event?.post(tap: .cghidEventTap)

            usleep(10000) // Adjust the speed of movement by changing the sleep duration
        }
    }
    
    private func getCurrentMouseLocation() -> CGPoint {
        if let screen = NSScreen.main {
            let mouseLocation = NSEvent.mouseLocation
            let screenHeight = screen.frame.height
            let flippedY = screenHeight - mouseLocation.y
            return CGPoint(x: mouseLocation.x, y: flippedY)
        }
        return .zero
    }
    
    private func leftClick() {
        let currentLocation = getCurrentMouseLocation()
        print("currentLocation:", currentLocation)

        let mouseDown = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: currentLocation, mouseButton: .left)
        let mouseUp = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: currentLocation, mouseButton: .left)

        mouseDown?.post(tap: .cghidEventTap)
        mouseUp?.post(tap: .cghidEventTap)
    }

    private func rightClick() {
        let currentLocation = getCurrentMouseLocation()
        print("currentLocation:", currentLocation)

        let mouseDown = CGEvent(mouseEventSource: nil, mouseType: .rightMouseDown, mouseCursorPosition: currentLocation, mouseButton: .right)
        let mouseUp = CGEvent(mouseEventSource: nil, mouseType: .rightMouseUp, mouseCursorPosition: currentLocation, mouseButton: .right)

        mouseDown?.post(tap: .cghidEventTap)
        mouseUp?.post(tap: .cghidEventTap)
    }
    
    private func pressRandomKey() {
        let keys = Array("abcdefghijklmnopqrstuvwxyz1234567890")
        if let randomKey = keys.randomElement() {
            let keyCode = CGKeyCode(randomKey.asciiValue!)
            let keyDown = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true)
            let keyUp = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: false)
            
            keyDown?.post(tap: .cghidEventTap)
            keyUp?.post(tap: .cghidEventTap)
        }
    }
    
    
    private func performAction() {
        let activeActions = states.keys.filter { states[$0] == true }
        if activeActions.isEmpty {
            print("No active actions")
        } else {
            if let randomAction = activeActions.randomElement() {
                print("Random active action: \(randomAction)")
                switch randomAction {
                case "Mouse movements":
                    moveMouseRandomly()
                case "Left clicks":
                    leftClick()
                case "Right clicks":
                    rightClick()
                case "Keyboard actions":
                    pressRandomKey()
                default:
                    break
                }
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

