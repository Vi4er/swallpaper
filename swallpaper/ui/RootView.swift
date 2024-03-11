//
//  Sidebar.swift
//  swallpaper
//
//  Created by Caleb Boatcallie on 3/7/24.
//

import SwiftUI

struct RootView: View {  
    @State var selectedItem: Tab = .wallpapers
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selectedItem: $selectedItem)
        } detail: {
            AnyView(selectedItem.content)
                .navigationTitle(selectedItem.name)
        }
    }
}



#Preview {
    RootView()
}
