//
//  SnapCarousel.swift
//  SwiftUIABC
//
//  Created by TrucPham on 18/08/2022.
//

import SwiftUI

struct SnapCarousel<Content: View, T: Identifiable> : View {
    var content: (T) -> Content
    var list : [T]
    var spacing : CGFloat
    var trailingSpace : CGFloat
    @Binding var index : Int
    init(spacing: CGFloat = 15, trailingSpace: CGFloat = 100, index: Binding<Int>, item : [T], @ViewBuilder content : @escaping (T) -> Content) {
        self.list = item
        self.spacing = spacing
        self.trailingSpace = trailingSpace
        self._index = index
        self.content = content
    }
    var body: some View {
        GeometryReader {proxy in
            HStack(spacing: spacing) {
                ForEach(list){item in
                    content(item)
                        .frame(width: proxy.size.width)
                }
            }
            .padding(.horizontal, spacing)
        }
    }
}

struct SnapCarousel_Previews: PreviewProvider {
    static var previews: some View {
        PagingView()
    }
}
