//
//  CardShimmer.swift
//  SwiftUIABC
//
//  Created by TrucPham on 20/06/2022.
//

import SwiftUI
struct CardShimmer : View {
    @State var isShow = false
    var body: some View {
        GeometryReader {geo in
            let center = geo.size.width + 50
            ZStack {
                Color.black.opacity(0.1)
                Color.white.mask(
                    Rectangle().fill(LinearGradient(colors: .init([.clear, .white.opacity(0.48), .clear]), startPoint: .top, endPoint: .bottom))
                        .rotationEffect(.init(degrees:-20))
                        .offset(x: self.isShow ? center: -center)
                        
                )
            }.onAppear(perform: {
                withAnimation(.default.speed(0.15).delay(0).repeatForever(autoreverses: false)){
                    self.isShow.toggle()
                }
            })
        }
        
    }
}
