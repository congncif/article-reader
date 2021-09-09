//
//  ReaderParseModel.swift
//  ArticleReader
//
//  Created by NGUYEN CHI CONG on 9/9/21.
//

import Combine
import Foundation

class ReaderParseModel: ObservableObject {
    @Published var content: ReaderContent?
    @Published var error: GeneralError?
    @Published var isLoading: Bool = false

    @LazyInjected var service: ReaderParseService

    private var cancellableSet = Set<AnyCancellable>()

    func parse(contentOf article: Article) {
        if content != nil { return } // load from cache

        guard !isLoading else { return } // avoid duplicated requests

        isLoading = true
        service.parse(contentOf: article.url.absoluteString)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self?.error = GeneralError(title: error.localizedDescription)
                }
                self?.isLoading = false
            } receiveValue: { [weak self] in
                self?.content = ReaderContent(title: $0.title,
                                              author: $0.author ?? article.author,
                                              content: $0.content,
                                              publishedDate: $0.publishedDate,
                                              domain: $0.domain)
            }
            .store(in: &cancellableSet)
    }
}
