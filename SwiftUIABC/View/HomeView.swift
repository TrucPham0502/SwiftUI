//
//  HomeView.swift
//  SwiftUIABC
//
//  Created by TrucPham on 15/06/2022.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 10) {
                    ForEach(0..<50, id: \.self){item in
                        NetworkImage(url: URL(string: "https://picsum.photos/200/200?id=\(item)"), placeholder: {
                            CardShimmer()
                        }).cornerRadius(10)
                    }
                }.padding(.bottom, 70)
            }.padding()
        }
        
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
