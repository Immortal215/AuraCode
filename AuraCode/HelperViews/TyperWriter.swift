import SwiftUI

struct TypewriterText: View {
    var fullText: String
    var speed : Double
    @State var displayedText = ""
    @State var currentIndex = 0

    var body: some View {
        Text(displayedText)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.system(.body, design: .monospaced))
            .onAppear {
                displayedText = ""
                currentIndex = 0
                Timer.scheduledTimer(withTimeInterval: 0.02 / Double(speed), repeats: true) { timer in
                    if currentIndex < fullText.count {
                        let index = fullText.index(fullText.startIndex, offsetBy: currentIndex)
                        displayedText.append(fullText[index])
                        currentIndex += 1
                    } else {
                        timer.invalidate()
                    }
                }
            }
    }
}

