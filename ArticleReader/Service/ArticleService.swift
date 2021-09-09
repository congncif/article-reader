//
//  ArticleService.swift
//  ArticleReader
//
//  Created by NGUYEN CHI CONG on 9/9/21.
//

import Alamofire
import Combine
import Foundation

enum ArticleError: Error {
    case serverError
    case invalidData
}

protocol ArticleService {
    func fetch() -> AnyPublisher<[Article], ArticleError>
}

final class ArticleProvider: ArticleService {
    private enum Configs {
        static let path = "https://bead-legendary-stygimoloch.glitch.me/articles"
    }

    func fetch() -> AnyPublisher<[Article], ArticleError> {
        return AF.request(Configs.path)
            .publishDecodable(type: [Article].self, queue: .init(label: "service.articles"))
            .value()
            .mapError { _ in
                ArticleError.serverError
            }
            .eraseToAnyPublisher()
    }
}
