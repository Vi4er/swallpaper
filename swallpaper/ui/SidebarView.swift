//
//  SidebarView.swift
//  swallpaper
//
//  Created by Caleb Boatcallie on 3/7/24.
//

import SwiftUI

enum TabSection: String, CaseIterable {
    case media
    case generative
    case cloud
    
    var name: String {
        rawValue.capitalized
    }
    
    var tabs: [Tab] {
        switch self {
        case .media: [.wallpapers, .screensavers, .clock, .menubar]
        case .generative: [.effects]
        default: []
        }
    }
}

enum Tab: String, Hashable, CaseIterable {
    case wallpapers
    case screensavers
    case clock
    case menubar
    case effects
    case settings
    
    var name: String {
        rawValue.capitalized
    }
    
    var icon: String {
        switch self {
        case .wallpapers: "display"
        case .screensavers: "moon.stars"
        case .clock: "clock"
        case .menubar: "menubar.rectangle"
        case .effects: "wand.and.stars"
        default: ""
        }
    }
    
    var content: any View {
        switch self {
        case .wallpapers:
            Text("LOL")
        default: Text(rawValue)
        }
    }
}

struct SidebarView: View {
    @Binding var selectedItem: Tab
    
    var body: some View {
        List(selection: $selectedItem) {
            ForEach(TabSection.allCases, id: \.rawValue) { section in
                Section(section.name) {
                    ForEach(section.tabs, id: \.self) { tab in
                        NavigationLink(value: tab) {
                            Label(tab.name, systemImage: tab.icon)
                        }
                    }
                }
            }
            
            NavigationLink(value: Tab.settings) {
                Label("Settings", systemImage: "gearshape")
            }
        }
        .listStyle(.sidebar)
    }
}

#Preview {
    SidebarView(selectedItem: .constant(.wallpapers))
}
