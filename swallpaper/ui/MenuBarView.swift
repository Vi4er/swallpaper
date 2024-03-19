//
//  MenuBarView.swift
//  swallpaper
//
//  Created by Caleb Boatcallie on 3/13/24.
//

import SwiftUI

struct MenuBarView: View {
    var body: some View {
        VStack {
            Grid {
                GridRow {
                    RoundedRectangle(cornerRadius: 10).onTapGesture {
                        print("???")
                    }.background(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: 10)
                }
                GridRow {
                    RoundedRectangle(cornerRadius: 10)
                    RoundedRectangle(cornerRadius: 10)
                }
            }
            .padding()
            
            .buttonStyle(.bordered)
            .padding()
        }
    }
}

#Preview {
    MenuBarView()
        .frame(width: 300, height: 250)
}
