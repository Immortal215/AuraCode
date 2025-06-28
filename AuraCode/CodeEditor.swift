import SwiftUI
import CodeEditor

struct CodeEditorView: View {
  
  @State var code = "let a = 42"
  @State var language = CodeEditor.Language.swift
    @State var theme = CodeEditor.availableThemes.first { $0.rawValue == "atom-one-dark" }!

  var body: some View {
    VStack(spacing: 0) {
      HStack {
        Picker("Language", selection: $language) {
          ForEach(CodeEditor.availableLanguages) { language in
            Text("\(language.rawValue.capitalized)")
              .tag(language)
          }
        }
        Picker("Theme", selection: $theme) {
          ForEach(CodeEditor.availableThemes) { theme in
            Text("\(theme.rawValue.capitalized)")
              .tag(theme)
          }
        }
      }
      .padding()
    
      Divider()
    
        CodeEditor(source: $code, language: language, theme: theme,  flags: [ .selectable, .editable, .smartIndent ], indentStyle: .softTab(width: 2), autoPairs: [ "{": "}", "<": ">", "'": "'", #"""#: #"""#, "(":")" ])
        
          .frame(minWidth: 640, minHeight: 480)

    }
  }
}


