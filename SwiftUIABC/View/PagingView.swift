//
//  PagingView.swift
//  SwiftUIABC
//
//  Created by TrucPham on 16/06/2022.
//

import SwiftUI

struct PagingView: View {
    
    @State var data : [String] = [
        "https://picsum.photos/250/340",
        "https://picsum.photos/250/340",
        "https://picsum.photos/250/340",
        "https://picsum.photos/250/340",
        "https://picsum.photos/250/340",
        "https://picsum.photos/250/340",
        "https://picsum.photos/250/340",
        "https://picsum.photos/250/340",
        "https://picsum.photos/250/340",
        "https://picsum.photos/250/340",
        "https://picsum.photos/250/340",
        "https://picsum.photos/250/340",
        "https://picsum.photos/250/340",
        "https://picsum.photos/250/340",
        "https://picsum.photos/250/340",
        "https://picsum.photos/250/340"
    ]
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(Array(data.enumerated()), id: \.1) {i in
                    GeometryReader {geo in
                        NetworkImage(url: URL(string: "\(i.1)?id=\(UUID().uuidString)"), placeholder: {
                            CardShimmer()
                            
                        }).cornerRadius(10).rotation3DEffect(.init(degrees: (Double(geo.frame(in: .global).midX) - (UIScreen.main.bounds.width / 2)) / -20), axis: (x: 0, y: 1, z: 0))
                    }.frame(width: 250, height: 340)
                }
            }.padding(.horizontal, (UIScreen.main.bounds.width - 250) / 2)
        }
    }
}


struct PagingView_Previews: PreviewProvider {
    static var previews: some View {
        PagingView()
    }
}
