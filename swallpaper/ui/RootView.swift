//
//  Sidebar.swift
//  swallpaper
//
//  Created by Caleb Boatcallie on 3/7/24.
//

import SwiftUI

struct Sidebar: View {
    @State private var isDefaultItemActive = true
    
    var body: some View {
        List {
            NavigationLink(destination: Text("LOL"), isActive: $isDefaultItemActive) {
                Label("Console", systemImage: "message")
            }
            // ...
        }.listStyle(SidebarListStyle())
    }
}

#Preview {
    Sidebar()
}
