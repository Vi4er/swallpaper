//
//  ContentView.swift
//  swallpaper
//
//  Created by Antfroze on 3/18/24.
//

import SwiftUI

enum Tab: String, CaseIterable {
    case library = "Your library"
    case cloud = "Cloud"
    case settings = "Settings"
    
    var image: String {
        switch self {
        case .library: "building.columns"
        case .cloud: "cloud"
        case .settings: "gearshape"
        }
    }
    
    var description: String {
        switch self {
        case .library: "Manage and edit all of your wallpapers"
        case .cloud: "Explore a vast selection of wallpapers."
        case .settings: "Update your Swallpaper preferences"
        }
    }
    
    var content: any View {
        switch self {
        case .library: WallpapersScreen()
        default: Text(rawValue)
        }
    }
}

struct TabView: View {
    var value: Tab
    @Binding var selection: Tab
    
    var body: some View {
        HStack {
            Image(systemName: "\(value.image)\(selection != value ? "" : ".fill")")
                .foregroundStyle(selection != value ? Color(NSColor.secondaryLabelColor) : Color(NSColor.labelColor))
                .bold()
            Text(value.rawValue)
                .foregroundStyle(selection != value ? Color(NSColor.secondaryLabelColor) : Color(NSColor.labelColor))
                .fontWeight(.medium)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(selection == value ? Color(NSColor.labelColor).opacity(0.1) : .clear)
        .clipShape(.rect(cornerRadius: Rounding.sm))
        .contentShape(.rect)
        .onTapGesture {
            selection = value
        }
    }
}

struct ContentView: View {
    @State private var selection: Tab = .library
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            ZStack {
                VStack(spacing: 6) {
                    ForEach(Tab.allCases.filter { $0 != .settings }, id: \.rawValue) { tab in
                        TabView(value: tab, selection: $selection)
                    }
                }
                .padding(.horizontal)
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.top, 1)
                
                VStack {
                    TabView(value: .settings, selection: $selection)
                }
                .padding(.horizontal)
                .padding(.bottom, Spacing.md)
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
            .toolbar(removing: .sidebarToggle)
        } detail: {
            AnyView(selection.content)
                .navigationTitle(selection.rawValue)
                .navigationSubtitle(selection.description)
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        SidebarToggleButton(selection: $selection)
                    }
                    
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: {}) {
                            Image(systemName: "info.circle")
                                .bold()
                        }
                    }
                }
        }
    }
}

struct SidebarToggleButton: View {
    @Binding var selection: Tab
    @State private var isHovered = false
    private let color = Color(NSColor.unemphasizedSelectedContentBackgroundColor)
    
    var body: some View {
        Image(systemName: "\(selection.image).fill")
            .resizable()
            .bold()
            .aspectRatio(contentMode: .fill)
            .frame(width: 16, height: 16)
            .padding(8)
            .background(isHovered ? Color.gray.opacity(0.45) : Color(NSColor.unemphasizedSelectedContentBackgroundColor))
            .clipShape(.rect(cornerRadius: Rounding.sm))
            .foregroundStyle(Color(NSColor.secondaryLabelColor))
            .padding(.trailing, Spacing.sm)
            .onTapGesture {
                NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar), with: nil)
            }
            .onHover(perform: { hovering in
                withAnimation(.linear(duration: 0.1)) {
                    isHovered = hovering
                }
            })
    }
}

#Preview {
    ContentView()
}
