//
//  Canvas.swift
//  SwiftUIABC
//
//  Created by TrucPham on 10/10/2022.
//

import SwiftUI

@available(iOS 15.0, *)
struct CanvasView: View {
    
    @State var dragOffset : CGSize = .zero
    @State var startAnimation : Bool = false
    
    var body: some View {
        VStack {
            clubbedView()
        }.ignoresSafeArea()
    }
    
    @ViewBuilder
    func clubbedView() -> some View {
        Rectangle().fill(LinearGradient(colors: [.black, .black], startPoint: .topLeading, endPoint: .bottomTrailing))
            .mask{
                TimelineView(.animation(minimumInterval: 2, paused: false)){ _ in
                    Canvas {context, size in
                        context.addFilter(.alphaThreshold(min: 0.5, color: .white))
                        
                        context.addFilter(.blur(radius: 6))
                        
                        context.drawLayer{ ctx in
                            for index in 1...3 {
                                if let resolvedView = context.resolveSymbol(id: index) {
                                    ctx.draw(resolvedView, at: .init(x: size.width / 2, y: 11 + 18))
                                }
                            }
                        }
                    } symbols: {
                        clubbedRoundedRectangle(isCircle: false).tag(1)
                        ForEach(2...3, id: \.self) { index in
                            let offset = startAnimation ? CGSize(width: .random(in: -180...180), height: .random(in: 0...180)) : .zero
                            clubbedRoundedRectangle(offset: offset).tag(index)
                        }
                    }
                }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            startAnimation.toggle()
        }
    }
    
    
    @ViewBuilder
    func clubbedRoundedRectangle(offset : CGSize = .zero, isCircle : Bool = true) -> some View {
        if isCircle {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(.white).frame(width: 37, height: 37).offset(offset)
                .animation(.easeInOut(duration: 2), value: offset)

        }
        else {
            Capsule().fill(.black).frame(width: 126, height: 37)
        }
        
    }
    
    @ViewBuilder
    func singleMetaBall() -> some View {
        Canvas {context, size in
            context.addFilter(.alphaThreshold(min: 0.5, color: .orange))
            
            context.addFilter(.blur(radius: 35))
            
            context.drawLayer{ ctx in
                for index in [1,2] {
                    if let resolvedView = context.resolveSymbol(id: index) {
                        ctx.draw(resolvedView, at: .init(x: size.width / 2, y: size.height / 2))
                    }
                }
            }
        } symbols: {
            ball().tag(1)
            
            ball(offset: dragOffset).tag(2)
        }
        .gesture(
            DragGesture().onChanged({ value in
                dragOffset = value.translation
            }).onEnded{_ in
                withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)){
                    dragOffset = .zero
                }
            }
        )
    }
    
    @ViewBuilder
    func ball(offset: CGSize = .zero) -> some View {
        Circle().fill(.white)
            .frame(width: 150, height: 150)
            .offset(offset)
    }
}

@available(iOS 15.0, *)
struct Canvas_Previews: PreviewProvider {
    static var previews: some View {
        CanvasView()
    }
}
