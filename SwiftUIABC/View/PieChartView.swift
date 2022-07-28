//
//  PieChartView.swift
//  SwiftUIABC
//
//  Created by TrucPham on 20/06/2022.
//

import SwiftUI

struct PieChartView: View {
    @Namespace var animation
    @State var isShow : Bool = false
    @State var isShow2 : Bool = false
    let data : [PieChartModel] = [
        .init(id: 2, percent: 0.1, color: .accentColor, name: "Kotlin"),
        .init(id: 3, percent: 0.1, color: .orange, name: "Java"),
        .init(id: 1, percent: 0.4, color: .green, name: "Swift"),
        .init(id: 4, percent: 0.05, color: .gray.opacity(0.7), name: "HTML"),
        .init(id: 5, percent: 0.05, color: .yellow, name: "CSS3"),
        .init(id: 6, percent: 0.2, color: Color.pink, name: "SwiftUI"),
        .init(id: 7, percent: 0.1, color: Color.purple, name: "Flutter"),
        
    ]
    var body: some View {
        VStack {
            ZStack {
                ForEach(0..<data.count, id: \.self){i in
                    ZStack {
                        let from : Float = data[0..<i].reduce(0.0) { partialResult, item in
                            return partialResult + item.percent
                        }
                        PieChartShape(fromPercent: isShow ? CGFloat(from) : 0, toPercent:  isShow ? CGFloat(from + data[i].percent) : 0)
                            .foregroundColor(data[i].color)
                            .animation(.spring(blendDuration: 0.2)).onAppear {
                                isShow = true
                            }
                    }
                }
            }
            .frame(height: 350)
           
            
            VStack {
                ZStack{
                    ForEach(data.indices, id: \.self) {i in
                        ZStack {
                            Circle().stroke(data[i].color.opacity(0.8), lineWidth: 15)
                            Circle()
                                .trim(from: 0, to: 1 - CGFloat(data[i].percent))
                                .stroke(data[i].color, style: StrokeStyle(lineWidth: 13, lineCap: .round, lineJoin: .round))
                                .rotationEffect(.init(degrees: 90))
                                .shadow(color: Color.black.opacity(0.5), radius: 5, x: 5, y: 5)
                               
                        }.padding(CGFloat(i) * 15)
                    }
                }.frame(width: 50, height: 150)
            }
            .padding(.horizontal)
            .padding(.vertical, 50)
            Spacer()
            
        }
        
    }
}



struct PieChartShape : Shape {
    typealias AnimatableData = CGFloat
    let fromPercent : CGFloat
    var toPercent : CGFloat
    
    var animatableData: AnimatableData {
        get { toPercent }
        set { toPercent = max(newValue, 0) }
    }
    func path(in rect: CGRect) -> Path {
        Path {path in
            let start = fromPercent * 360
            let end = toPercent * 360
            guard start < end else {
                path.closeSubpath()
                return
            }
            let center : CGPoint = .init(x: rect.midX, y: rect.midY)
            path.move(to: center)
            path.addArc(center: center, radius: 160, startAngle: .init(degrees: start), endAngle: .init(degrees: end), clockwise: false)
            path.closeSubpath()
        }
    }
}

struct PieChartModel : Identifiable {
    let id : Int
    let percent : Float
    let color : Color
    let name : String
    
}


struct PieChartView_Previews: PreviewProvider {
    static var previews: some View {
        PieChartView()
    }
}



