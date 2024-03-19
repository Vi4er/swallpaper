//
//  Button.swift
//  swallpaper
//
//  Created by Caleb Boatcallie on 3/18/24.
//

import SwiftUI

struct CButton: View {
    enum Style {
        
    }
    
    var body: some View {
        HStack {
            Text("LOL")
        }
        .background(VisualEffectView().ignoresSafeArea())
    }
}

#Preview {
    CButton()
        .frame(width: 250, height: 250)
}

struct VisualEffectView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let effectView = NSVisualEffectView()
        effectView.state = .active
        return effectView
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
    }
}
