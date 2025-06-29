import SwiftUI
import CodeEditor

struct CodeEditorView: View {
    
    @Binding var code: String
    @State var language = CodeEditor.Language.python
    @State var theme = CodeEditor.availableThemes.first { $0.rawValue == "tomorrow-night" }!
    @State var fontSize: CGFloat = 14
    @State var playButtonHover = false
    @State var playing = false
    @Binding var output : String
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    runCode()
                } label: {
                    Image(systemName: playing ? (playButtonHover ? "stop.fill" : "stop") : (playButtonHover ? "play.fill" : "play"))
                }
                .onHover { hovering in
                    withAnimation(.snappy(duration: 0.3)) {
                        playButtonHover = hovering
                    }
                }
                
                Picker("Language", selection: $language) {
                    Text("Python").tag(CodeEditor.Language.python)
                    Text("JavaScript").tag(CodeEditor.Language.javascript)
                }

                Picker("Theme", selection: $theme) {
                    ForEach(CodeEditor.availableThemes) { theme in
                        Text("\(theme.rawValue.capitalized)").tag(theme)
                    }
                }
            }
            .padding()

            Divider()

            HStack(alignment: .top, spacing: 0) {
                ScrollView(.vertical) {
                    VStack(alignment: .trailing, spacing: 2) {
                        ForEach(0..<code.components(separatedBy: .newlines).count, id: \.self) { i in
                            Text("\(i + 1)")
                                .font(.system(size: fontSize, design: .monospaced))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 4)
                                .padding(.top, -2)
                        }
                    }
                    .padding(.top, 10)
                }
                 
                CodeEditor(
                    source: $code,
                    language: language,
                    theme: theme,
                    fontSize: $fontSize,
                    flags: [.selectable, .editable, .smartIndent],
                    indentStyle: .softTab(width: 2),
                    autoPairs: ["{": "}", "<": ">", "'": "'", #"""#: #"""#, "(": ")"]
                )
            }
            .frame(minWidth: 640, minHeight: 480)

            Divider()

            VStack(alignment: .leading) {
                Text("Output:")
                    .font(.headline)
                    .padding(.bottom, 2)
                ScrollView {
                    Group {
                        if output.isEmpty {
                            Text("No output yet.")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(.body, design: .monospaced))
                        } else if !playing {
                            TypewriterText(fullText: output, speed: 20)
                        } else if playing {
                            Text("Running...")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(.body, design: .monospaced))
                        }
                    }
                    .padding(8)
                    .foregroundStyle(.secondary)
                    .background(.black)
                    .cornerRadius(8)
                }
                .frame(minHeight: 100)
            }
            .padding()
        }
    }

    func runCode() {
        playing = true
        let tempDirectory = FileManager.default.temporaryDirectory

        let langConfig: (String, String)? = {
            switch language {
            case .python:
                return ("py", "/usr/bin/python3")
            case .javascript:
                return ("js", "/usr/local/bin/node")
            default:
                return nil
            }
        }()

        guard let (ext, path) = langConfig else {
            output = "Unsupported language selected."
            playing = false
            return
        }

        let fileURL = tempDirectory.appendingPathComponent("script.\(ext)")

        do {
            try code.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            playing = false
            output = "Failed to write script: \(error)"
            return
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = [fileURL.path]

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        do {
            try process.run()
            process.waitUntilExit()

            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

            let out = String(data: outputData, encoding: .utf8) ?? ""
            let err = String(data: errorData, encoding: .utf8) ?? ""

            DispatchQueue.main.async {
                output = process.terminationStatus == 0 ? out : err
                playing = false
            }
        } catch {
            DispatchQueue.main.async {
                playing = false
                output = "Failed to run script: \(error)"
            }
        }
    }
}
