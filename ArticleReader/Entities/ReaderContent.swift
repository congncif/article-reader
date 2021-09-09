//
//  ReaderContent.swift
//  ArticleReader
//
//  Created by NGUYEN CHI CONG on 9/9/21.
//

import Foundation

struct ReaderContent {
    let title: String
    let author: String?
    let content: String
    let publishedDate: Date?
    let domain: String?
}

extension ReaderContent {
    var publishedDateDisplay: String? {
        if let date = publishedDate {
            return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
        }
        return nil
    }
}
