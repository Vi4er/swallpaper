//
//  MenuBar.swift
//  swallpaper
//
//  Created by Antfroze on 3/21/24.
//

import SwiftUI

struct MenuBarView: View {
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: Spacing.md) {
                HStack(spacing: Spacing.md) {
                    VStack {

                    }
                    .frame(height: 80)
                    .frame(maxWidth: .infinity)
                    .background(.gray.opacity(0.35))
                    .clipShape(.rect(cornerRadius: Rounding.md))
                    
                    VStack {
                        
                    }
                    .frame(height: 80)
                    .frame(maxWidth: .infinity)
                    .background(.gray.opacity(0.35))
                    .clipShape(.rect(cornerRadius: Rounding.md))
                }
                
                HStack(spacing: Spacing.md) {
                    VStack {
                        
                    }
                    .frame(height: 80)
                    .frame(maxWidth: .infinity)
                    .background(.gray.opacity(0.35))
                    .clipShape(.rect(cornerRadius: Rounding.md))

                    VStack {
                        
                    }
                    .frame(height: 80)
                    .frame(maxWidth: .infinity)
                    .background(.gray.opacity(0.35))
                    .clipShape(.rect(cornerRadius: Rounding.md))
                }
            }
            .padding()
            
            Divider()
            
            HStack(alignment: .center) {
                Button("Feedback") {}
                    .buttonStyle(.plain)
                Button("Help") {}
                    .buttonStyle(.plain)
                Button("Quit") {
                    exit(0)
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, Spacing.sm)
        }
    }
}
