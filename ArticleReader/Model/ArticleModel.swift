//
//  ArticleModel.swift
//  ArticleReader
//
//  Created by NGUYEN CHI CONG on 9/9/21.
//

import Combine
import Foundation

class ArticleModel: ObservableObject {
    @Published var contents: [Article] = []
    @Published var error: GeneralError?
    @Published var isLoading: Bool = false

    @LazyInjected var service: ArticleService

    private var cancellableSet = Set<AnyCancellable>()

    func fetch() {
        isLoading = true
        service.fetch()
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self?.error = GeneralError(title: error.localizedDescription)
                }
                self?.isLoading = false
            } receiveValue: { [weak self] values in
                self?.contents = values
            }
            .store(in: &cancellableSet)
    }
}
