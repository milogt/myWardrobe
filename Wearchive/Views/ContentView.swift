//
//  ContentView.swift
//  Wearchive
//
//  Created by Guo Tian on 3/6/21.
//

import SwiftUI

struct ContentView: View {
    
    @State private var isActive:Bool = false

    var body: some View {
        
        VStack {
            if isActive {
                TabView{
                    ArchiveView().tabItem { Label("Archive", systemImage:"crown.fill") }
                    ClosetView().tabItem { Label("Wardrobe", systemImage:"doc.text.below.ecg") }
                }
                .accentColor(.purple)
            } else {
                // display splash screen on launch and disapper after a period of time
                SplashView()
                    .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation {
                            self.isActive = true
                        }
                    }
                    // save the date info on first launch
                    // if date info exists, log the date
                    if let firstOpen = UserDefaults.standard.object(forKey: "FirstOpen") as? Date {
                        print("The app was first opened on \(firstOpen)")
                    } else {
                        UserDefaults.standard.set(Date(), forKey: "FirstOpen")
                    }
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
