//
//  HomeView.swift
//  SwiftUIABC
//
//  Created by TrucPham on 15/06/2022.
//

import SwiftUI

struct MainView: View {
    @Namespace var tabBarEffect
    @State var currentTab : Tab = .home
    var body: some View {
        VStack {
            TabView(selection: $currentTab) {
                HomeView()
                Text("Cart").tag(Tab.cart)
                Text("Favourite").tag(Tab.favourite)
                Text("Profile").tag(Tab.profile)
            }
            .overlay(CustomTabbar(currentTab: $currentTab, tabBarEffect: tabBarEffect), alignment: .bottom)
            .tabViewStyle(.page)
        }
        
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
