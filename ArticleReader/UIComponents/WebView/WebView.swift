//
//  WebView.swift
//  ArticleReader
//
//  Created by NGUYEN CHI CONG on 9/9/21.
//

import SwiftUI
import UIKit
import WebKit

struct WebView: UIViewControllerRepresentable {
    typealias UIViewControllerType = WebViewController

    @Binding var progress: Double

    let url: URL

    func makeUIViewController(context: Context) -> WebViewController {
        let webViewController = WebViewController(progressHandler: {
            progress = $0
        })
        let request = URLRequest(url: url)
        webViewController.loadRequest(request)
        return webViewController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
