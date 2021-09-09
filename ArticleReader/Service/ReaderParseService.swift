//
//  ReaderParseService.swift
//  ArticleReader
//
//  Created by NGUYEN CHI CONG on 9/9/21.
//

import Alamofire
import Combine
import Foundation

enum ReaderParseError: Error {
    case serverError
    case invalidData
}

protocol ReaderParseService {
    func parse(contentOf url: String) -> AnyPublisher<ReaderContent, ReaderParseError>
}

class ReaderParser: ReaderParseService {
    private enum Configs {
        static let path = "https://mercury-parser-demo.glitch.me/parser"
    }

    func parse(contentOf url: String) -> AnyPublisher<ReaderContent, ReaderParseError> {
        let params: [String: Any] = ["url": url]

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return AF.request(Configs.path, method: .post, parameters: params)
            .publishDecodable(type: DecodedReaderContent.self, queue: .init(label: "service.reader-parser"), decoder: decoder)
            .value()
            .tryCompactMap {
                guard let title = $0.title, let content = $0.content else {
                    throw ReaderParseError.invalidData
                }

                return ReaderContent(
                    title: title,
                    author: $0.author,
                    content: content,
                    publishedDate: $0.datePublished,
                    domain: $0.domain
                )
            }
            .mapError { _ in
                ReaderParseError.serverError
            }
            .eraseToAnyPublisher()
    }
}

struct DecodedReaderContent: Decodable {
    let title: String?
    let author: String?
    let content: String?
    let datePublished: Date?
    let leadImageUrl: URL?
    let dek: String?
    let url: URL?
    let domain: String?
    let excerpt: String?
    let wordCount: Int?
    let direction: String?
    let totalPages: Int?
    let renderedPages: Int?
    let nextPageUrl: URL?
}
