import SwiftUI


struct ProgressBarView: View {
    @State var progressBarSize : CGFloat = 1
    var aura : Int
    var body: some View {
        HStack {
            ZStack {
               
                RoundedRectangle(cornerRadius: 15)
                    .saturation(0.2)
                    .opacity(0.8)
                
                RoundedRectangle(cornerRadius: 15)
                    .stroke(lineWidth: 3)
                    .foregroundStyle(.black)
                HStack {
                    RoundedRectangle(cornerRadius: 15)
                        .frame(width: 100)
                        .saturation(0.6)
                        .overlay {
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(lineWidth: 3)
                                .foregroundStyle(.black)
                        }
                    Spacer()
                }
                
                HStack {
                    Spacer()
                    
                    Text("\(aura)")
                        .monospaced()
                        .foregroundStyle(.black)
            
                    VStack {
                        
                        Text("🔥")
                            .padding(.horizontal)
                        if progressBarSize != 1 {
                            Text("Aura")
                            // .scaleEffect(progressBarSize == 1 ? 0 : 1)
                            //  .opacity(1)
                                .transition(.scale(scale: 0, anchor: .center))
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
            .foregroundStyle(.purple)
            .frame(width: 500 * progressBarSize, height: pow(30, progressBarSize) * progressBarSize * progressBarSize * progressBarSize)
            .scaleEffect(progressBarSize)
            .onHover { hovering in
                if hovering {
                    withAnimation(.smooth(extraBounce: 0.5)) {
                        progressBarSize = 1.05
                    }
                } else {
                    withAnimation(.smooth(extraBounce: 0.5)) {
                        progressBarSize = 1
                    }
                }
                
            }
            .fixedSize()
        }
        .padding()
        
    }
}
