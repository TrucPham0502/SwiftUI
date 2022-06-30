//
//  CircleView.swift
//  SwiftUIABC
//
//  Created by TrucPham on 20/06/2022.
//

import SwiftUI

struct TimerView: View {
    let max = 15
    @State var start : Bool = false
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var count = 0
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .trim(from: 0, to: 1)
                    .stroke(.black.opacity(0.09), style: StrokeStyle(lineWidth: 35))
                    .frame(width: 280, height: 280)
                
                Circle()
                    .trim(from: 0, to: CGFloat(self.count) / 15)
                    .stroke(AngularGradient(colors: [.red, .orange, .red], center: .center), style: StrokeStyle(lineWidth: 35, lineCap: .round))
                    .rotationEffect(.init(degrees: -90))
                    .frame(width: 280, height: 280)
                    .shadow(radius: 6)
                    .animation(.spring())
                VStack {
                    Text("\(count)")
                        .font(.system(size: 65).bold())
                    Text("Of \(max)")
                        .font(.title)
                }
            }
            
            HStack(spacing: 30) {
                Button {
                    self.start.toggle()
                } label: {
                    HStack {
                        Image(systemName: self.start ? "pause.fill" : "play.fill")
                            .foregroundColor(.white)
                        Text(self.start ? "Pause" : "Play")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .padding(.horizontal)
                    .background(Color.orange)
                    .clipShape(Capsule())
                    .shadow(radius: 6)
                }
                
                Button {
                    count = 0
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.orange)
                        Text("Restart")
                            .foregroundColor(.orange)
                    }
                    .padding()
                    .padding(.horizontal)
                    .background(Capsule().stroke(Color.orange, lineWidth: 3))
                    .shadow(radius: 6)
                }
                .disabled(count == 0)
                
            }.padding(.top, 50)
            
        }.onReceive(self.timer) { _ in
            if self.start {
                if count == max {
                    self.start = false
                    count = 0
                }
                else { count = min(max, count + 1) }
            }
            else {
                count = 0
            }
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}
