import SwiftUI

//struct ChunkyButton: ButtonStyle {
//    @State var color : Color
//    var body: some
//
//
//}

struct ChunkButton: View {
    @State var hovering = false
    var color : Color
    var text : Text?
    var symbol : Image?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .stroke(.black, lineWidth: 3)
                .offset(y: 6)
                .opacity(0.5)
                .saturation(0.6)
            
            
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .stroke(.black, lineWidth: 3)
                .saturation(hovering ? 0.6 : 0.3)
                .offset( y: hovering ? 5 : 0)
                
            
            ZStack {
                if symbol == nil {
                    if text != nil {
                        text
                    } else {
                        Image(systemName: "checkmark")
                    }
                } else {
                    symbol
                }
            }
            .padding(8)
            .offset(y: hovering ? 5 : 0)
            
        }
        .fixedSize()
        .padding()
        .onHover { isHovering in
            if isHovering {
                withAnimation(.snappy(duration: 0.3)) {
                    hovering = true
                }
            } else {
                withAnimation(.snappy(duration: 0.3)) {
                    hovering = false
                }
            }
        }
        
    }
    
}


extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.currentIndex = hex.startIndex

        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = Double((rgbValue & 0xFF0000) >> 16) / 255
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255
        let b = Double(rgbValue & 0x0000FF) / 255

        self.init(red: r, green: g, blue: b)
    }
}

extension Font.TextStyle {
    var size: CGFloat {
        switch self {
        case .largeTitle: return 34
        case .title: return 28
        case .title2: return 22
        case .title3: return 20
        case .headline: return 17
        case .body: return 17
        case .callout: return 16
        case .subheadline: return 15
        case .footnote: return 13
        case .caption: return 12
        case .caption2: return 11
        @unknown default: return 14
        }
    }
}
