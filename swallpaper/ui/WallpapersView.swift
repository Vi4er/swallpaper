import SwiftUI

struct WallpapersView: View {
    static let wallpaperSize: CGFloat = 200
    static let spacing: CGFloat = 16
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: Self.wallpaperSize), spacing: Self.spacing), count: 3), spacing: Self.spacing) {
                ForEach(0..<2, id: \.self) { value in
                    WallpaperView()
                }
                
                PlusView()
            }.padding()
        }
    }
}

struct PlusView: View {
    @State private var isHovering = false
    
    var body: some View {
        ZStack {
            Image(systemName: "plus")
                .font(.system(size: 48))
                .bold()
                .foregroundStyle(isHovering ? .accent : Color(.labelColor))
        }
        .frame(width: WallpapersView.wallpaperSize, height: WallpapersView.wallpaperSize * 0.6)
        .background(isHovering ? .accent.withAlphaComponent(0.15) : .controlBackgroundColor.withAlphaComponent(0.15))
        .clipShape(.rect(cornerRadius: 10))
        .background {
            RoundedRectangle(cornerRadius: 10)
                .stroke((isHovering ? Color.accentColor : .white).opacity(0.15), lineWidth: 2)
        }
        .onHover { hovering in
            withAnimation(.linear(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }
}

struct WallpaperView: View {
    @State private var isHovering = false
    
    var body: some View {
        Image(.frame)
            .resizable()
            .clipShape(.rect(cornerRadius: 10))
            .blur(radius: isHovering ? 3 : 0)
            .frame(width: WallpapersView.wallpaperSize, height: WallpapersView.wallpaperSize * 0.6)
            .onHover { hovering in
                withAnimation {
                    isHovering = hovering
                }
            }
            .overlay {
                if isHovering {
                    ZStack {
                        Text("LOL")
                            .font(.largeTitle)
                            .bold()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        .black.opacity(0.45),
                        in: RoundedRectangle(cornerRadius: 10)
                    )
                    .allowsHitTesting(false)
                }
            }
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.white.opacity(0.15), lineWidth: 2)
            }
    }
}

#Preview {
    RootView()
}
