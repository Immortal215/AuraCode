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
                .offset(x: 6, y: 6)
                .opacity(0.5)
                .saturation(0.6)
            
            
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .stroke(.black, lineWidth: 3)
                .saturation(hovering ? 0.6 : 0.3)
                .offset(x: hovering ? 5 : 0, y: hovering ? 5 : 0)
                
            
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
            .offset(x: hovering ? 5 : 0, y: hovering ? 5 : 0)
            
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
