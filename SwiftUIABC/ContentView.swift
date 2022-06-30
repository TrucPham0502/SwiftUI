//
//  ContentView.swift
//  SwiftUIABC
//
//  Created by TrucPham on 10/06/2022.
//

import SwiftUI

struct ContentView: View {
    @Namespace var menuEffect
    var menu : [String] = [ "Home", "HScroll", "Pie Chart", "Save Cards", "Settings", "Help"]
    @State var tabSelected : Int = 0
    @State var isShow : Bool = false
    init(){
        UITabBar.appearance().isHidden = true
    }
    var body: some View {
        GeometryReader {geo in
            ZStack(alignment: .topLeading) {
                VStack(alignment: .leading) {
                    HStack {
                        NetworkImage(url: URL(string: "https://picsum.photos/60/60"), placeholder: {
                            CardShimmer()
                        })
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .padding(.vertical)
                            .padding(.leading)
                            .opacity(isShow ? 1 : 0)
                        VStack(alignment: .leading) {
                            Text("Truc Pham")
                                .font(.system(size: 20).bold())
                                .padding(.bottom, 2)
                            Text("TP HCM").font(.system(size: 12))
                        }
                        .padding(.leading, 10)
                        
                    }
                    ZStack(alignment: .topLeading) {
                        VStack(alignment: .leading) {
                            let count = menu.count
                            ForEach(0..<count, id: \.self) {index in
                                HStack(alignment: .center) {
                                    if  index == self.tabSelected {
                                        Color.orange
                                            .cornerRadius(5)
                                            .frame(width: 5, height: 30, alignment: .leading)
                                            .matchedGeometryEffect(id: "menuEffect", in: menuEffect)
                                            .padding(.top)
                                            .offset(y: -15)
                                    }
                                    else {
                                        Color.clear
                                            .frame(width: 5, height: 30, alignment: .leading).padding(.top)
                                            .offset(y: -15)
                                    }
                                    Button {
                                        withAnimation(.spring(blendDuration: 0.3)){
                                            self.tabSelected = index
                                        }
                                    } label: {
                                        Text(menu[index])
                                            .font(.system(size: 20))
                                            .foregroundColor(.black)
                                    }.padding(.bottom)
                                    
                                }
                                
                            }
                        }.padding(.leading, 10)
                            .padding(.vertical)
                        
                    }.padding(.leading)
                }.offset(x: self.isShow ? 0 : -200)
                
                
                
                MenuView(isShow: $isShow, tabSelected: $tabSelected, menuEffect: menuEffect)
                    .cornerRadius(isShow ? 15 : 0)
                    .background(
                        isShow ? RoundedRectangle(cornerRadius: 15)
                            .fill(.white)
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 5, y: 5) : RoundedRectangle(cornerRadius: 0)
                            .fill(.white)
                            .shadow(color: .clear, radius: 0, x: 0, y:0)
                    )
                    .scaleEffect(self.isShow ? 0.7 : 1)
                    .offset(x: self.isShow ? 140 : 0, y: isShow ? 20 : 0)
                //                    .rotationEffect(.init(degrees: self.isShow ? 7 : 0))
                    .rotation3DEffect(.init(degrees: self.isShow ? 60 : 0), axis: (0,-1,0))
                
                
            }
        }
        
        
        
        
    }
    
}


struct MenuView : View {
    @Binding var isShow : Bool
    @Binding var tabSelected : Int
    var menuEffect : Namespace.ID
    var body: some View {
        ZStack {
            VStack {
                HStack(alignment: .center){
                    Button {
                        withAnimation(.spring(blendDuration: 0.3)){
                            self.isShow.toggle()
                        }
                    } label: {
                        Image(systemName: "list.bullet")
                            .resizable()
                            .foregroundColor(.black)
                            .frame(width: 20, height: 20)
                    }
                    Spacer()
                    Text("Home").font(.system(size: 22).bold())
                    Spacer()
                    NetworkImage(url: URL(string: "https://picsum.photos/35/35"), placeholder: {
                        CardShimmer()
                    })
                        .frame(width: 35, height: 35)
                        .clipShape(Circle()).opacity(isShow ? 0 : 1)
                }
                .frame(height: 35)
                .padding(.horizontal)
                .padding(.horizontal, 10)
                TabView(selection: $tabSelected) {
                    MainView().tag(0)
                    PagingView().tag(1)
                    PieChartView().tag(2)
                    Text("Save Cards").tag(3)
                    Text("Settings").tag(4)
                    Text("Help").tag(5)
                }
            }
            if isShow {
                Color.white.opacity(0.00001).onTapGesture {
                    withAnimation(.spring()){
                        self.isShow = false
                    }
                }
            }
        }
    }
}









struct DetailPage : View {
    var body: some View {
        Text("Detail View")
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


