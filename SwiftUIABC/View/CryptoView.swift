//
//  CryptoView.swift
//  SwiftUIABC
//
//  Created by TrucPham on 22/07/2022.
//

import SwiftUI

struct CryptoView: View {
    @Namespace var animation
    @State var currentCoin = "BTC"
    @StateObject var viewModel : CryptoModel = .init()
    var body: some View {
        VStack {
            if let coins = viewModel.coins, let coin = viewModel.currentCoin {
                HStack(spacing: 15) {
                    NetworkImage(url: URL(string: coin.image!), placeholder: {
                        CardShimmer()
                    })
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50).aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
                        
                    VStack(alignment: .leading, spacing: 5) {
                        Text(coin.name ?? "")
                            .foregroundColor(.white)
                            .font(.callout)
                        Text(coin.symbol?.uppercased() ?? "")
                            .foregroundColor(.gray)
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
                
                customControl(coins: coins)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(coin.currentPrice?.convertToCurrency() ?? "")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    Text("\(coin.priceChange24H ?? 0 > 0 ? "+" : "")\(String(format: "%.2f", coin.priceChange24H ?? 0))")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(coin.priceChange24H ?? 0 < 0 ? Color.white : Color.black)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule().fill(coin.priceChange24H ?? 0 < 0 ? Color.red : Color.green)
                        )
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                graphView(coin: coin)
                control()
            }
            else {
                ProgressView()
            }
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.9).ignoresSafeArea())
        
    }
    
    @ViewBuilder
    func customControl(coins : [CoingeckoResponseElement]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(coins) { coin in
                    Text(coin.symbol?.uppercased() ?? "")
                        .foregroundColor(currentCoin == coin.symbol?.uppercased() ? .white : .gray)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 16)
                        .contentShape(Rectangle())
                        .background(
                            currentCoin == coin.symbol?.uppercased() ? Rectangle().fill(Color.gray)
                                .matchedGeometryEffect(id: "SEGMENTEDTAB", in: animation) : nil
                        )
                        .onTapGesture {
                            viewModel.currentCoin = coin
                            withAnimation{
                                currentCoin = coin.symbol?.uppercased() ?? ""
                            }
                        }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
    
    @ViewBuilder
    func control() -> some View {
        HStack(spacing: 20){
            Button {
                
            } label: {
                Text("Sell")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.red)
                    )
            }
            
            Button {
                
            } label: {
                Text("Buy")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.green)
                    )
            }
        }
    }
    
    @ViewBuilder
    func graphView(coin: CoingeckoResponseElement) -> some View {
        if let data = coin.sparklineIn7D?.price {
            GeometryReader {_ in
                LineGraph(data: data, profit: coin.priceChange24H ?? 0 > 0)
            }
            .padding(.vertical, 30)
            .padding(.horizontal, -10)
        }
    }
    
}


struct CryptoView_Previews: PreviewProvider {
    static var previews: some View {
        CryptoView()
    }
}


class CryptoModel : ObservableObject {
    @Published var coins : [CoingeckoResponseElement]?
    @Published var currentCoin : CoingeckoResponseElement?
    
    init(){
        fetchData()
    }
    
    func fetchData()  {
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=10&page=1&sparkline=true&price_change_percentage=7d") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            print(response!)
            do {
                let json = try JSONDecoder().decode([CoingeckoResponseElement].self, from: data!)
                DispatchQueue.main.async {
                    self.coins = json
                    if let firstCoin = json.first {
                        self.currentCoin = firstCoin
                    }
                }
            } catch {
                print("error")
            }
        })

        task.resume()
        
    }
}



// MARK: - CoingeckoResponseElement
struct CoingeckoResponseElement: Codable, Identifiable {
    let id, symbol, name: String?
    let image: String?
    let currentPrice: Double?
    let marketCap, marketCapRank: Int?
    let fullyDilutedValuation: Int?
    let totalVolume: Int?
    let high24H, low24H, priceChange24H, priceChangePercentage24H: Double?
    let marketCapChange24H, marketCapChangePercentage24H, circulatingSupply: Double?
    let totalSupply: Double?
    let maxSupply: Int?
    let ath, athChangePercentage: Double?
    let athDate: String?
    let atl, atlChangePercentage: Double?
    let atlDate: String?
    let roi: Roi?
    let lastUpdated: String?
    let sparklineIn7D: SparklineIn7D?
    let priceChangePercentage7DInCurrency: Double?

    enum CodingKeys: String, CodingKey {
        case id, symbol, name, image
        case currentPrice = "current_price"
        case marketCap = "market_cap"
        case marketCapRank = "market_cap_rank"
        case fullyDilutedValuation = "fully_diluted_valuation"
        case totalVolume = "total_volume"
        case high24H = "high_24h"
        case low24H = "low_24h"
        case priceChange24H = "price_change_24h"
        case priceChangePercentage24H = "price_change_percentage_24h"
        case marketCapChange24H = "market_cap_change_24h"
        case marketCapChangePercentage24H = "market_cap_change_percentage_24h"
        case circulatingSupply = "circulating_supply"
        case totalSupply = "total_supply"
        case maxSupply = "max_supply"
        case ath
        case athChangePercentage = "ath_change_percentage"
        case athDate = "ath_date"
        case atl
        case atlChangePercentage = "atl_change_percentage"
        case atlDate = "atl_date"
        case roi
        case lastUpdated = "last_updated"
        case sparklineIn7D = "sparkline_in_7d"
        case priceChangePercentage7DInCurrency = "price_change_percentage_7d_in_currency"
    }
}

// MARK: - Roi
struct Roi: Codable {
    let times: Double?
    let currency: String?
    let percentage: Double?
}

// MARK: - SparklineIn7D
struct SparklineIn7D: Codable {
    let price: [Double]?
}

typealias CoingeckoResponse = [CoingeckoResponseElement]


