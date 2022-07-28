//
//  waterSliderView.swift
//  SwiftUIABC
//
//  Created by TrucPham on 01/07/2022.
//

import SwiftUI

struct waterSliderView: View {
    @State var phase : CGFloat = 0
    var body: some View {
        ZStack{
            WaterShape(progress: 0.5, phase: phase)
                .fill(LinearGradient(colors: [.white, .blue], startPoint: .leading, endPoint: .bottom))
                .clipShape(Capsule())
            Capsule()
                .stroke(.gray.opacity(0.8), lineWidth: 10)
        }.frame(width: 250, height: 250, alignment: .center)
            .onAppear{
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                    self.phase = .pi * 2
                }
            }
        
    }
}

struct waterSliderView_Previews: PreviewProvider {
    static var previews: some View {
        waterSliderView()
    }
}


struct WaterShape : Shape {
    let progress : CGFloat
    var amplitude : CGFloat = 15
    var waveLength : CGFloat = 20
    var phase : CGFloat
    
    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        Path {path in
            let width = rect.width
            let height = rect.height
            let midWidth = width/2
            let progressHeight = height * (1 - progress)
            //            let amplitude = CGFloat.random(in: 0...10)
            
            path.move(to: .init(x: 0, y: progressHeight))
            
            for x in stride(from: 0, to: width + 15, by: 5) {
                let relativeX = x / waveLength
                let normalizedLength = (x - midWidth) / midWidth
                let y = progressHeight + sin(phase + relativeX) * amplitude + normalizedLength
                path.addLine(to: .init(x: x, y: y))
            }
            //            path.addLine(to: .init(x: width, y: progressHeight))
            path.addLine(to: .init(x: width, y: height))
            path.addLine(to: .init(x: 0, y: height))
            path.addLine(to: .init(x: 0, y: progressHeight))
        }
        
    }
}
