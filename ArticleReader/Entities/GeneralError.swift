//
//  GeneralError.swift
//  ArticleReader
//
//  Created by NGUYEN CHI CONG on 9/9/21.
//

import Foundation

struct GeneralError: Identifiable, Error {
    var id = UUID()
    let title: String
}
