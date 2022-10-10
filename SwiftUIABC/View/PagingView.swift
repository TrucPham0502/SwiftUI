//
//  PagingView.swift
//  SwiftUIABC
//
//  Created by TrucPham on 16/06/2022.
//

import SwiftUI

struct PagingModel : Identifiable {
    let url : String
    var id : String = UUID().uuidString
}

struct PagingView: View {
    @State var index : Int = 0
    @State var data : [PagingModel] = [
        .init(url: "https://picsum.photos/720/1340?id=1"),
        .init(url: "https://picsum.photos/720/1340?id=2"),
        .init(url: "https://picsum.photos/720/1340?id=3"),
        .init(url: "https://picsum.photos/720/1340?id=4"),
        .init(url: "https://picsum.photos/720/1340?id=5"),
        .init(url: "https://picsum.photos/720/1340?id=6"),
        .init(url: "https://picsum.photos/720/1340?id=7"),
        .init(url: "https://picsum.photos/720/1340?id=8"),
        .init(url: "https://picsum.photos/720/1340?id=9"),
        .init(url: "https://picsum.photos/720/1340?id=10"),
        .init(url: "https://picsum.photos/720/1340?id=11"),
        .init(url: "https://picsum.photos/720/1340?id=12"),
        .init(url: "https://picsum.photos/720/1340?id=13"),
        .init(url: "https://picsum.photos/720/1340?id=14"),
        .init(url: "https://picsum.photos/720/1340?id=15"),
    ]
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                SnapCarousel(index: $index, item: data) { item in
                    GeometryReader {proxy in
                        NetworkImage(url: URL(string: item.url), placeholder: {
                            CardShimmer()
                            
                        }).frame(width: proxy.size.width)
                    }
                }
            }
        }
    }
}


struct PagingView_Previews: PreviewProvider {
    static var previews: some View {
        PagingView()
    }
}
