//
//  Spotlight.swift
//  SwiftUIABC
//
//  Created by TrucPham on 20/07/2022.
//

import SwiftUI

extension View {
    @ViewBuilder
    func addSpotlight(_ id : Int, shape: SpotlightShape = .rectangle, roudedRadius: CGFloat = 0, text: String = "") -> some View {
        self.anchorPreference(key: BoundsKey.self, value: .bounds, transform: {
            return [id : .init(shape: shape, anchor: $0, text: text, radius: roudedRadius)]
        })
    }
    
    @ViewBuilder
    func addSpotlightOverlay(_ show : Binding<Bool>, currentSpot : Binding<Int>) -> some View {
        self.overlayPreferenceValue(BoundsKey.self, {values in
            GeometryReader{proxy in
                if let preference = values.first(where: {item in
                    item.key == currentSpot.wrappedValue
                }){
                    let screenSize = proxy.size
                    let anchor = proxy[preference.value.anchor]
                    spotlightHelperView(screenSize: screenSize, rect: anchor, show: show, currentSpot: currentSpot, properties: preference.value) {
                        if currentSpot.wrappedValue <= values.count {
                            currentSpot.wrappedValue += 1
                        }
                        else  {
                            show.wrappedValue = false
                        }
                    }
                }
            }
            .ignoresSafeArea()
            .animation(.easeInOut, value: show.wrappedValue)
            .animation(.easeInOut, value: currentSpot.wrappedValue)
        })
    }
    
    
    @ViewBuilder
    func spotlightHelperView(screenSize : CGSize, rect : CGRect, show: Binding<Bool>, currentSpot : Binding<Int>, properties : BoundsKeyProperties, _ onTap: @escaping () -> ()) -> some View {
        if #available(iOS 15.0, *) {
            Rectangle().fill(.ultraThinMaterial).environment(\.colorScheme, .dark)
                .overlay(alignment: .topLeading) {
                    GeometryReader{proxy in
                        let textAttr = NSAttributedString(string: properties.text, attributes: [.font : UIFont.preferredFont(forTextStyle: .title2)])
                        let constraintBox = CGSize(width: proxy.size.width, height: .greatestFiniteMagnitude)
                        let textSize = textAttr.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).integral.size
                          
                         
                        Text(properties.text)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .offset(x: (rect.minX + textSize.width) > (screenSize.width - 20) ? -(textSize.width - rect.width + 20) : 0)
                            .offset(y: (rect.maxY + textSize.height) > (screenSize.height - 50) ? -(rect.height + 60) : 30)
                    }
                    .offset(x: rect.minX, y: rect.maxY)
                    
                }
                .opacity(show.wrappedValue ? 1 : 0)
                .mask(
                    Rectangle().overlay(alignment: .topLeading){
                        let radius = properties.shape == .circle ? (rect.width + 10 / 2)
                        : (properties.shape == .rectangle ? 0 : properties.radius)
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .frame(width: rect.width + 10, height: rect.height + 10)
                            .offset(x: rect.minX - 5, y: rect.minY - 5)
                            .blendMode(.destinationOut)
                            
                    }
                )
                .onTapGesture {
                    onTap()
                }
        } else {
            // Fallback on earlier versions
        }
    }
}

enum SpotlightShape {
    case circle
    case rectangle
    case rounded
}

struct BoundsKey : PreferenceKey {
    static func reduce(value: inout [Int : BoundsKeyProperties], nextValue: () -> [Int : BoundsKeyProperties]) {
        value.merge(nextValue(), uniquingKeysWith: {$1})
    }
    
    static var defaultValue: [Int : BoundsKeyProperties] = [:]
}

struct BoundsKeyProperties {
    var shape : SpotlightShape
    var anchor : Anchor<CGRect>
    var text : String = ""
    var radius : CGFloat = 0
}

struct Spotlight_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
