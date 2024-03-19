//
//  View+Extension.swift
//  swallpaper
//
//  Created by Caleb Boatcallie on 3/13/24.
//

import SwiftUI

extension View {
    func background(_ nsColor: NSColor) -> some View {
        self.background(Color(nsColor))
    }
}
