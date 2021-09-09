//
//  ReaderView.swift
//  ArticleReader
//
//  Created by NGUYEN CHI CONG on 9/9/21.
//

import Foundation
import SwiftUI

struct ReaderView: UIViewControllerRepresentable {
    typealias UIViewControllerType = WebViewController
    
    @Binding var progress: Double
    
    let content: ReaderContent
    
    func makeUIViewController(context: Context) -> WebViewController {
        let webView = ReaderWebView()
        let viewController = WebViewController(webView: webView) {
            progress = $0
        }
        webView.load(readerContent: content)
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: WebViewController, context: Context) {}
}
