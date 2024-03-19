//
//  OnboardingSignInScreen.swift
//  swallpaper
//
//  Created by Caleb Boatcallie on 3/18/24.
//

import SwiftUI

struct OnboardingSignInScreen: View {
    @State private var username: String = ""
    
    var body: some View {
        VStack {
            TextField("LOL", text: $username)
                .padding()
        }
    }
}

#Preview {
    OnboardingSignInScreen()
        .frame(width: 1280/2, height: 720/2)
}
