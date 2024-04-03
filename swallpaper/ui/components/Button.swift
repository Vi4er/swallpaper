//
//  Button.swift
//  swallpaper
//
//  Created by Antfroze on 3/20/24.
//

import SwiftUI

struct CButton<Content: View>: View {
    var action: () -> Void
    var content: () -> Content
    var tintColor: Color
    
    @State private var isHovering = false
    var startOpacity = 0.25
    var endOpacity = 0.5
    
    init(action: @escaping () -> Void, content: @escaping () -> Content, tintColor: Color = .gray) {
        self.action = action
        self.content = content
        self.tintColor = tintColor
        
        if tintColor != .gray {
            startOpacity = 0.8
            endOpacity = 1
        }
    }
    
    var body: some View {
        ZStack {
            content()
        }
        .padding(.vertical, Spacing.xs)
        .padding(.horizontal, Spacing.sm)
        .background(isHovering ? tintColor.opacity(endOpacity) : tintColor.opacity(startOpacity))
        .clipShape(.rect(cornerRadius: Rounding.sm))
        .onHover { hovering in
            isHovering = hovering
        }
        .onTapGesture {
            action()
        }
    }
}

extension CButton {
    func tinted(_ color: Color) -> CButton {
        CButton(action: action, content: content, tintColor: color)
    }
}
