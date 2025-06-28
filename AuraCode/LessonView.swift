import SwiftUI

struct LessonView: View {
    @Binding var code : String
    var body: some View {
        GeometryReader { geo in
        ZStack {
            HStack {
                ScrollView {
                    HStack {
                        ChunkButton(color: .purple, symbol: Image(systemName: "square.on.square"))
                        ChunkButton(color: .purple, symbol: Image(systemName: "square.on.square"))
                        ChunkButton(color: .purple, symbol: Image(systemName: "square.on.square"))
                    }
                    Text("What the sigma ohi rizz What the sigma ohi rizz What the sigma ohi rizz What the sigma ohi rizz What the sigma ohi rizz What the sigma ohi rizz What the sigma ohi rizz What the sigma ohi rizz What the sigma ohi rizz What the sigma ohi rizz What the sigma ohi rizz What the sigma ohi rizz What the sigma ohi rizz What the sigma ohi rizz What the sigma ohi rizz What the sigma ohi rizz What the sigma ohi rizz What the sigma ohi rizz What the sigma ohi rizz What the sigma ohi rizz ")
                        .padding()
                }
                Divider()
                
                CodeEditorView(code: $code)
                    .padding()
                    .padding(.top, 50)
                    .frame(width: geo.size.width * 2/3)
            }
        }
        .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}
