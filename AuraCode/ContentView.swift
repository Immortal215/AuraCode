import SwiftUI
import CodeEditorView
import LanguageSupport

struct ContentView: View {
    @State var code = ""
    @State var textSelection : TextSelection? = nil
    @AppStorage("aura") var aura = 0 
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
                    
                    TextEditor(text: $code, selection: $textSelection)
                        .textEditorStyle(.automatic)
                        .foregroundStyle(.secondary)
                        .padding()
                        .frame(width: geo.size.width * 2/3)
                        
                }
                
                VStack {
                    ProgressBarView()

                    Spacer()
                }
                

            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

#Preview {
    ContentView()
}
