//
//  Article.swift
//  ArticleReader
//
//  Created by NGUYEN CHI CONG on 9/9/21.
//

import Foundation

struct Article: Identifiable, Decodable {
    let id: String
    let title: String
    let subtitle: String
    let thumbnail: URL
    let url: URL
    let author: String
}
