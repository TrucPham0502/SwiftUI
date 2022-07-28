//
//  CustomTabbar.swift
//  SwiftUIABC
//
//  Created by TrucPham on 15/06/2022.
//

import SwiftUI

struct CustomTabbar: View {
    @Binding var currentTab : Tab
    var tabBarEffect : Namespace.ID
    @State var currentXValue : CGFloat = 0
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.rawValue){tab in
                tabButton(tab: tab)
                    .overlay(
                        Text(tab.getText())
                            .foregroundColor(Color.black)
                            .font(.system(size: 14, weight: .semibold))
                            .offset(y: currentTab == tab ? 15 : 30)
                            .opacity(currentTab == tab ? 1 : 0)
                    ).animation(.spring())
            }
        }
        .padding(.vertical)
        .padding(.bottom, 10)
        .background(
            Color.white.clipShape(BottomCurve(centerX: self.getCenterXValue())).shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -5)
                .ignoresSafeArea(.container, edges: .bottom).matchedGeometryEffect(id: "shapeEffect", in: tabBarEffect).animation(.spring())
               
        )
    }
    func getCenterXValue() -> CGFloat {
        let width = UIScreen.main.bounds.width / CGFloat(Tab.allCases.count)
        guard let index = Tab.allCases.firstIndex(where: { $0.rawValue == currentTab.rawValue }) else { return 0 }
        return (width * CGFloat((index + 1))) - width / 2
    }
    @ViewBuilder
    func tabButton(tab: Tab) -> some View {
        GeometryReader{proxy in
            Button{
                withAnimation(.spring()) {
                    currentTab = tab
                } 
            } label: {
                Image(systemName: tab.rawValue)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                    .addSpotlight(tab.getSpotlightI(), shape: .circle, roudedRadius: 0, text: tab.getText())
                    .frame(maxWidth: .infinity)
                    .foregroundColor(currentTab == tab ? .white : .black)
                    .padding(currentTab == tab ? 15 : 0)
                    .background(
                        currentTab == tab ?  Circle().fill(Color.orange)
                            .matchedGeometryEffect(id: "tabBarEffect", in: tabBarEffect) : nil
                    ).contentShape(Rectangle())
                    .offset(y: currentTab == tab ? -50 : 0)
                   
            }
            
        }.frame(height:30)
    }
}

struct CustomTabbar_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

enum Tab : String, CaseIterable {
    case home = "house.circle"
    case cart = "cart.circle"
    case favourite = "heart.circle"
    case profile = "person.crop.circle"
    func getSpotlightI() -> Int {
        switch self {
        case .home: return 3
        case .cart: return 4
        case .favourite: return 5
        case .profile: return 6
        }
    }
    func getText() -> String {
        switch self {
        case .home: return "Home"
        case .cart: return "Cart"
        case .favourite: return "Favourite"
        case .profile: return "Profile"
        }
    }
}
struct BottomCurve: Shape {
    var animatableData: CGFloat {
        get { return centerX }
        set { centerX = newValue }
    }
    var centerX : CGFloat
    func path(in rect: CGRect) -> Path {
        print("centerX: \(centerX)")
        let f : CGFloat = 20
        let b : CGFloat = 10
        let padding : CGFloat = 10
        let imageSize : CGFloat = 45
        
        return Path {path in
            path.move(to: .zero)
            path.addLine(to: .init(x: centerX - (imageSize / 2) - padding - f, y: 0))
            
            path.addQuadCurve(to: .init(x: centerX - (imageSize / 2) - padding, y: b), control: .init(x: centerX - (imageSize / 2) - (f), y: 0))
            
            path.addQuadCurve(to: .init(x: centerX + (imageSize / 2) + padding, y: b), control: .init(x: centerX , y: (imageSize / 2) + padding + b))
            
            path.addQuadCurve(to: .init(x: centerX + (imageSize / 2) + padding + f, y: 0), control: .init(x: centerX + (imageSize / 2) + padding + (f/2), y: 0))
            
            path.addLine(to: .init(x: rect.maxX, y: 0))
            path.addLine(to: .init(x: rect.maxX, y: rect.maxY))
            path.addLine(to: .init(x: 0, y: rect.maxY))
        }
    }
}
