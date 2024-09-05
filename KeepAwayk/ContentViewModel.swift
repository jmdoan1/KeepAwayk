//
//  ContentViewModel.swift
//  KeepAwayk
//
//  Created by Justin Doan on 7/7/24.
//

import AppKit
import Carbon.HIToolbox.Events

class ContentViewModel: ObservableObject {
    let options = [
        "Mouse movements",
        "Left clicks",
        "Right clicks",
        "Keyboard actions"
    ]
    
    @Published var states: [String: Bool]
    @Published var isRunning = false
    @Published var interval: Int = 5
    @Published var hasSubscription = false
    
    private var eventMonitor: EventMonitor?
    init() {
        self.states = Dictionary(uniqueKeysWithValues: options.map { ($0, true) })
        
        self.eventMonitor = EventMonitor(mask: .keyDown) { [weak self] event in
            if event?.modifierFlags.contains(.command) == true && event?.characters == "y" {
                self?.toggleRunning()
            }
        }
    }
    
    func startEventMonitor() {
        self.eventMonitor?.start()
    }
    
    func stopEventMonitor() {
        self.eventMonitor?.stop()
    }
    
    func toggleRunning() {
        isRunning.toggle()
        if isRunning {
            startActions()
        } else {
            AppDelegate.shared.showPopover(nil)
        }
    }
    
    private func startActions() {
        performAction(isFirst: true)
        
        Timer.scheduledTimer(withTimeInterval: Double(interval), repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            if !self.isRunning {
                timer.invalidate()
                AppDelegate.shared.showPopover(nil)
                return
            }
            self.performAction()
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
        
        let mouseDown = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: currentLocation, mouseButton: .left)
        let mouseUp = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: currentLocation, mouseButton: .left)
        
        mouseDown?.post(tap: .cghidEventTap)
        mouseUp?.post(tap: .cghidEventTap)
    }
    
    private func rightClick() {
        let currentLocation = getCurrentMouseLocation()
        
        let mouseDown = CGEvent(mouseEventSource: nil, mouseType: .rightMouseDown, mouseCursorPosition: currentLocation, mouseButton: .right)
        let mouseUp = CGEvent(mouseEventSource: nil, mouseType: .rightMouseUp, mouseCursorPosition: currentLocation, mouseButton: .right)
        
        mouseDown?.post(tap: .cghidEventTap)
        mouseUp?.post(tap: .cghidEventTap)
    }
    
    let keyCodeMapping: [Character: CGKeyCode] = [
        "a": 0, "b": 11, "c": 8, "d": 2, "e": 14, "f": 3, "g": 5, "h": 4,
        "i": 34, "j": 38, "k": 40, "l": 37, "m": 46, "n": 45, "o": 31, "p": 35,
        "q": 12, "r": 15, "s": 1, "t": 17, "u": 32, "v": 9, "w": 13, "x": 7,
        "y": 16, "z": 6, "1": 18, "2": 19, "3": 20, "4": 21, "5": 23, "6": 22,
        "7": 26, "8": 28, "9": 25, "0": 29
    ]
    
    func pressRandomKey() {
        let keys = Array("abcdefghijklmnopqrstuvwxyz1234567890")
        if let randomKey = keys.randomElement(), let keyCode = keyCodeMapping[randomKey] {
            let keyDown = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true)
            let keyUp = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: false)
            keyDown?.post(tap: .cghidEventTap)
            keyUp?.post(tap: .cghidEventTap)
        }
    }
    
    private func performAction(isFirst: Bool = false) {
        let activeActions = states.keys.filter { states[$0] == true && !(isFirst && $0 == "Left clicks") }
        
        if activeActions.isEmpty {
            print("No active actions")
        } else {
            if let randomAction = activeActions.randomElement() {
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
