import SwiftUI

struct OnboardingScreen: View {
    @State private var hueOffset: Double = 0
    
    var body: some View {
        ZStack {
            VisualEffectView().ignoresSafeArea()
            
            VStack(spacing: Spacing.sm) {
                LinearGradient(gradient: Gradient(colors: [Color(hue: hueOffset, saturation: 1, brightness: 1), Color(hue: hueOffset + 0.2, saturation: 1, brightness: 1)]), startPoint: .top, endPoint: .bottom)
                    .mask(Image(.logo)
                        .resizable()
                        .aspectRatio(contentMode: .fit))
                    .frame(width: 64, height: 64)
                    .onAppear {
                        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                            withAnimation {
                                hueOffset += 0.01
                            }
                        }
                        RunLoop.main.add(timer, forMode: .common)
                    }
                
                Text("Welcome to Swallpaper")
                    .font(.title)
                    .bold()
                
                Text("Effortlessly enhance your desktop experience with intuitive controls at your fingertips.")
                    .frame(maxWidth: 450)
                    .multilineTextAlignment(.center)
            }
            
            HStack {
                Button("Skip setup") {
                    
                }
                .buttonStyle(.borderless)
                
                Spacer()
                
                Button("Begin setup") {
                    
                }
            }
            .padding()
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
    }
}

#Preview {
    OnboardingScreen()
        .frame(width: 1280/2, height: 720/2)
}
