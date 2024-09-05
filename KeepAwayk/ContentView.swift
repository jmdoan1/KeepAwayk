//
//  ContentView.swift
//  KeepAwayk
//
//  Created by Justin Doan on 7/7/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @State private var showPopup = false
    
    var body: some View {
        VStack {
            Text("KeepAwayk").font(.largeTitle).fontWeight(.bold).padding()
            ForEach(viewModel.options, id: \.self) { key in
                Toggle(key, isOn: Binding<Bool>(
                    get: { viewModel.states[key] ?? false },
                    set: { viewModel.states[key] = $0 }
                ))
                .toggleStyle(CheckboxToggleStyle(viewModel: viewModel, showPopup: $showPopup))
            }
            
            HStack {
                Stepper("Do something every \(viewModel.interval)", value: $viewModel.interval)
                Text("seconds")
            }
            
            Divider()
            
            Button(action: {
                viewModel.toggleRunning()
            }) {
                Text(viewModel.isRunning ? "Stop (⌘ + Y)" : "Start (⌘ + Y)")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                    .foregroundColor(.white)
            }
            .background(viewModel.isRunning ? Color.red : Color.blue).cornerRadius(10)
            .keyboardShortcut("y", modifiers: .command)
        }
        .padding()
        .onAppear {
            viewModel.startEventMonitor()
            IAPManager.shared.fetchProducts()
        }
        .onDisappear {
            viewModel.stopEventMonitor()
        }
        .sheet(isPresented: $showPopup) {
            SubscriptionPopupView(isVisible: $showPopup)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    @ObservedObject var viewModel: ContentViewModel
    @Binding var showPopup: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                .resizable()
                .frame(width: 20, height: 20)
                .onTapGesture {
                    configuration.isOn.toggle()
                }
        }
        .padding()
    }
}
