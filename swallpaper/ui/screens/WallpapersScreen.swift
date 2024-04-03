//
//  WallpapersScreen.swift
//  swallpaper
//
//  Created by Antfroze on 3/18/24.
//

import SwiftUI
import Glur
import RiveRuntime
@_spi(Advanced) import SwiftUIIntrospect

struct Wallpaper: Hashable {
    let name: String
    let image: NSImage
    
    static let testData: [Wallpaper] = [
        .init(name: "Winter's Blossom", image: .winter),
        .init(name: "Car", image: .car)
    ].reversed()
}

struct WallpapersScreen: View {
    @State private var selectedWallpaper: Wallpaper?
    @State private var showSidebar = false

    var body: some View {
        GeometryReader {
            let size = $0.size
            let rowCount = max(Int(size.width / 250), 1)
            let sidebarSize = min(350, size.width / 2)
            
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(spacing: Spacing.md), count: rowCount), spacing: Spacing.md) {
                    ForEach(Wallpaper.testData, id: \.hashValue) { wp in
                        WallpaperView(wallpaper: wp, selected: $selectedWallpaper)
                            .onTapGesture {
                                selectedWallpaper = wp
                                
                                withAnimation(.spring(duration: 0.25, bounce: 0.2)) {
                                    showSidebar = true
                                }
                            }
                    }
                }
                .padding()
            }
            .overlay {
                SlideInSidebar(showSidebar: $showSidebar, selectedWallpaper: $selectedWallpaper, sidebarSize: sidebarSize)
            }
        }
    }
}

struct WallpaperView: View {
    let wallpaper: Wallpaper
    @Binding var selected: Wallpaper?
    
    @State private var isHovering = false
    @State private var position = 0.0
    @State private var animate = false
    @State private var fade = false
    
    var body: some View {
        ZStack {
            Image(nsImage: wallpaper.image)
                .resizable()
                .blur(radius: isHovering ? 5 : 0)
                .glur(radius: 12.0,
                      offset: 0.6,
                      interpolation: 0.4,
                      direction: .down
                )
                .scaleEffect(isHovering ? 1.2 : 1)
                .allowsHitTesting(false)
            
            VStack(alignment: .leading) {
                Text(wallpaper.name)
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(.black.opacity(0.65))
            .overlay(Rectangle().frame(width: nil, height: 1, alignment: .top).foregroundColor(Color.white.opacity(0.15)), alignment: .top)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .allowsHitTesting(false)
            .offset(y: isHovering ? 35 : 0)
        }
        .onHover { hovering in
            withAnimation {
                isHovering = hovering
            }
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
        .overlay {
            if isHovering {
                ZStack {
                    Color.black.opacity(0.65).ignoresSafeArea()
                    
                    VStack(spacing: -8) {
                        RiveViewModel(fileName: "binoculars").view()
                            .frame(width: 48, height: 48)
                            .opacity(0.5)
                    
                        Text("VIEW WALLPAPER")
                            .foregroundStyle(.white)
                            .font(.title3)
                            .bold()
                    }
                }
                .allowsHitTesting(false)
            }
        }
        .clipShape(.rect(cornerRadius: Rounding.md))
        .overlay {
            RoundedRectangle(cornerRadius: Rounding.md)
                .stroke(.black, lineWidth: 2)
            RoundedRectangle(cornerRadius: Rounding.md)
                .stroke(.gray.opacity(0.4), lineWidth: 1)
        }
        .padding(Spacing.xs)
        .overlay {
            Rectangle()
                .foregroundStyle(LinearGradient(colors: [.clear, .clear, .clear, Color(NSColor.labelColor), .clear, .clear, .clear], startPoint: .leading, endPoint: .trailing))
                .scaleEffect(2.5)
                .rotationEffect(animate ? .degrees(360) : .zero)
                .animation(animate ? .linear(duration: 5).repeatForever(autoreverses: false) : .default, value: animate)
                .mask {
                    RoundedRectangle(cornerRadius: Rounding.md + Spacing.xs)
                        .stroke(lineWidth: 3)
                }
                .opacity(fade ? 1 : 0)
                .allowsHitTesting(false)
        }
        .onChange(of: selected) { _, newValue in
            if newValue != nil && newValue == wallpaper {
                animate = true
                withAnimation(.linear(duration: 0.25)) {
                    fade = true
                }
            } else {
                withAnimation(.linear(duration: 0.25)) {
                    fade = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    animate = false
                }
            }
        }
    }
}

struct SlideInSidebar: View {
    @Binding var showSidebar: Bool
    @Binding var selectedWallpaper: Wallpaper?
    var sidebarSize: Double
    
    @State private var fps = 70.0
    @State private var displayFps = 70.0
    
    @State private var playbackSpeed = 1.0
    @State private var displayPlaybackSpeed = 1.0

    @State private var starred = false
    
    var body: some View {
        if let selectedWallpaper = self.selectedWallpaper {
            VStack(alignment: .leading, spacing: Spacing.md) {
                    HStack {
                        CButton {
                            withAnimation(.spring(duration: 0.25, bounce: 0.2)) {
                                showSidebar = false
                            }
                        } content: {
                            Image(systemName: "chevron.right")
                                .bold()
                        }
                        
                        Text(selectedWallpaper.name)
                            .font(.title3)
                            .bold()
                            .frame(maxWidth: .infinity)
                        
                        CButton {
                            
                        } content: {
                            Image(systemName: "square.and.pencil")
                                .bold()
                        }
                    }
                    
                    Image(nsImage: selectedWallpaper.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 100)
                        .clipShape(.rect(cornerRadius: Rounding.md))
                        .allowsHitTesting(false)
                    
                    ScrollView {
                        VStack(spacing: Spacing.md) {
                            CSection(title: "INFO") {
                                Group {
                                    HStack {
                                        Text("Dimensions")
                                            .bold()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Text("1920x1080")
                                            .fontWeight(.medium)
                                            .monospaced()
                                            .foregroundStyle(Color(NSColor.secondaryLabelColor))
                                    }
                                    
                                    HStack {
                                        Text("Size")
                                            .bold()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Text("130")
                                            .fontWeight(.medium)
                                            .monospaced()
                                            .foregroundStyle(Color(NSColor.secondaryLabelColor)) +
                                        Text("MB")
                                            .fontWeight(.medium)
                                            .foregroundStyle(Color(NSColor.secondaryLabelColor))
                                    }
                                    
                                    HStack {
                                        Text("Type")
                                            .bold()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Text("Video (MP4)")
                                            .fontWeight(.medium)
                                            .foregroundStyle(Color(NSColor.secondaryLabelColor))
                                    }
                                }
                            }
                            
                            CSection(title: "PROPERTIES") {
                                Group {
                                    HStack {
                                        HStack {
                                            Text("FPS")
                                                .bold()
                                            Text(displayFps.formatted())
                                                .font(.system(size: 10))
                                                .fontWeight(.medium)
                                                .monospaced()
                                                .contentTransition(.numericText())
                                                .foregroundStyle(Color(NSColor.secondaryLabelColor))
                                                .padding(.horizontal, 4)
                                                .background(.gray.opacity(0.15))
                                                .clipShape(.rect(cornerRadius: 2))
                                        }
                                        .frame(width: sidebarSize / 3, alignment: .leading)

                                        Slider(value: $fps, in: 30...120, step: 10) {}
                                        minimumValueLabel: {
                                            Text("30")
                                        } maximumValueLabel: {
                                            Text("120")
                                        }
                                    }
                                    .onChange(of: fps) { _, newValue in
                                        withAnimation(.default.speed(2)) {
                                            displayFps = newValue
                                        }
                                    }
                                    
                                    HStack {
                                        HStack {
                                            Text("Playback Speed")
                                                .bold()
                                            Text("\(displayPlaybackSpeed.formatted())x")
                                                .font(.system(size: 10))
                                                .fontWeight(.medium)
                                                .monospaced()
                                                .contentTransition(.numericText())
                                                .foregroundStyle(Color(NSColor.secondaryLabelColor))
                                                .padding(.horizontal, 4)
                                                .background(.gray.opacity(0.15))
                                                .clipShape(.rect(cornerRadius: 2))
                                        }
                                        .frame(width: sidebarSize / 2, alignment: .leading)

                                        Slider(value: $playbackSpeed, in: 0.5...2, step: 0.5) {}
                                        minimumValueLabel: {
                                            Text("0.5")
                                        } maximumValueLabel: {
                                            Text("2")
                                        }
                                    }
                                    .onChange(of: playbackSpeed) { _, newValue in
                                        withAnimation(.default.speed(2)) {
                                            displayPlaybackSpeed = newValue
                                        }
                                    }
                                }
                            }

                            CSection(title: "MENUBAR") {
                                Group {
                                    HStack {
                                        Text("Enabled")
                                            .bold()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                        
                                        Toggle("", isOn: .constant(false))
                                            .toggleStyle(.switch)
                                            .controlSize(.small)
                                    }
                                    
                                    HStack {
                                        Text("Color")
                                            .bold()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                        
                                        GradientColorPicker()
                                    }
                                    
                                    HStack {
                                        Text("Effect")
                                            .bold()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                        
                                        Picker("", selection: .constant("Static")) {
                                            Text("Static")
                                                .tag("Static")
                                            Text("Wave")
                                                .tag("Wave")
                                        }
                                        .controlSize(.small)
                                    }
                                }
                            }

                        }
                        .frame(maxWidth: .infinity)
                    }
                    .introspect(.scrollView, on: .macOS(.v11...)) { scrollView in
                        scrollView.scrollerStyle = .overlay
                    }
                                       
                    HStack {
                        CButton {
                            
                        } content: {
                            Text("Remove from Library")
                                .bold()
                                .frame(maxWidth: .infinity)
                        }
                        .tinted(.red)
                        
                        CButton {
                            starred.toggle()
                        } content: {
                            Image(systemName: "star\(starred ? ".fill" : "")")
                                .bold()
                        }
                        .tint(starred ? .yellow : .gray)
                    }
                }
                .padding()
                .frame(width: sidebarSize)
                .background {
                    Color(NSColor.windowBackgroundColor)
                        .overlay(Color.black.opacity(0.35))
                }
                .overlay(Rectangle().frame(width: 0.75, height: nil, alignment: .leading).foregroundColor(Color.black), alignment: .leading)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                .offset(x: showSidebar ? 0 : sidebarSize)
            
        }
    }
}

struct CSection<Content: View>: View {
    let title: String
    let content: () -> Content
    
    @State private var isExpanded: Bool = true
    
    init(title: String, content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }
    
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text(title)
                    .font(.footnote)
                    .bold()
                    .foregroundStyle(Color(NSColor.secondaryLabelColor))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.footnote)
                    .bold()
                    .foregroundStyle(Color(NSColor.secondaryLabelColor))
            }
            .contentShape(.rect)
            .padding(.vertical, 4)
            .overlay(Rectangle().frame(width: nil, height: 1, alignment: .bottom).foregroundColor(Color.white.opacity(0.15)), alignment: .bottom)
            .onTapGesture {
                withAnimation(.default.speed(2)) {
                    isExpanded.toggle()
                }
            }
            
            if isExpanded {
                content()
            }
        }
    }
}

struct GradientColorPicker: NSViewControllerRepresentable {
    typealias NSViewControllerType = NSGradientColorPicker
    
    func makeNSViewController(context: Context) -> NSGradientColorPicker {
        return NSGradientColorPicker()
    }
    
    func updateNSViewController(_ nsViewController: NSGradientColorPicker, context: Context) {
        
    }
}

class NSGradientColorPicker: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Create an array which hold the initial colors you want to show on the track
        let initialGradientColors = [
            TNGradientColor(location: 0.0, color: NSColor.red),
            TNGradientColor(location: 1.0, color: NSColor.blue)
        ]
        
        let track = TNGradientPickerSliderConfiguration.Track(height: 8, borderColor: NSColor.black.withAlphaComponent(0.3), borderWidth: 1)
        let colorHandle = TNGradientPickerSliderConfiguration.ColorHandle(radius: 6, innerRadius: 3, outerCircleColor: NSColor.white, outerCircleBorderColor: NSColor.black.withAlphaComponent(0.3), outerCircleBorderWidth: 1.0, innerCircleBorderColor: NSColor.black.withAlphaComponent(0.3), innerCircleBorderWidth: 1.0)
        
        let config = TNGradientPickerSliderConfiguration(track: track, colorHandle: colorHandle)
        
        // 2. Create the view controller
        let gradientSliderViewController = TNGradientPickerSliderViewController(configuration: config, gradientColors: initialGradientColors)
        
        // 3. Add it as a child view controller of the current view controller
        addChild(gradientSliderViewController)
        
        // 4. Add it to the view hierarchy + setup the constraints
        view.addSubview(gradientSliderViewController.view)
        
        // 5. Register some object to be the delegate which will receive information when the colors array has changed.
        gradientSliderViewController.delegate = self
    }
}

extension NSGradientColorPicker: TNGradientSliderViewControllerDelegate {
   func gradientSliderViewController(_ viewController: TNGradientPickerSliderViewController, didUpdate gradientColors: [TNGradientColor]) {
    }
   
}

#Preview {
    WallpapersScreen()
}
