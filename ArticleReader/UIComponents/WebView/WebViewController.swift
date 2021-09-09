//
//  WebViewController.swift
//  ArticleReader
//
//  Created by NGUYEN CHI CONG on 9/9/21.
//

import Foundation
import UIKit
import WebKit

final class WebViewController: UIViewController {
    init(webView: WKWebView = WKWebView(), progressHandler: @escaping ((Double) -> Void)) {
        self.webView = webView
        self.progressHandler = progressHandler
        super.init(nibName: nil, bundle: Bundle(for: WebViewController.self))
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        self.webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(webView)

        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
    }

    func loadRequest(_ request: URLRequest) {
        webView.load(request)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case "estimatedProgress":
            progressHandler?(webView.estimatedProgress)
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    private var webView: WKWebView
    private let progressHandler: ((Double) -> Void)?
}
