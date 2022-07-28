//
//  NetworkImage.swift
//  SwiftUIABC
//
//  Created by TrucPham on 17/06/2022.
//

import Combine
import SwiftUI
struct NetworkImage<Content : View> : View {
    @StateObject private var viewModel = NetworkImageViewModel()
    var url: URL? {
        didSet {
            viewModel.loadImage(from: url) 
        }
    }
    let placeholder: Content
    init(url: URL?, @ViewBuilder placeholder: () -> Content) {
        self.url = url
        self.placeholder = placeholder()
    }
    var body: some View {
        Group {
            if let data = viewModel.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if viewModel.isLoading {
                placeholder
            } else {
                placeholder
            }
        }
        .onAppear {
            viewModel.loadImage(from: url)
        }
        .onChange(of: url) { newValue in
            viewModel.loadImage(from: newValue)
        }
    }
   
}

class NetworkImageViewModel: ObservableObject {
    @Published var imageData: Data?
    @Published var isLoading = false
    private static let cache = NSCache<NSURL, NSData>()
    
    private var cancellables = Set<AnyCancellable>()
    
    func loadImage(from url: URL?) {
        print("URL Loading: \(url)")
        isLoading = true
        guard let url = url else {
            isLoading = false
            return
        }
        if let data = Self.cache.object(forKey: url as NSURL) {
            imageData = data as Data
            isLoading = false
            return
        }
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                if let data = $0 {
                    Self.cache.setObject(data as NSData, forKey: url as NSURL)
                    self?.imageData = data
                }
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }
}
