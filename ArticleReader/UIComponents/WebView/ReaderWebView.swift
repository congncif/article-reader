//
//  ReaderWebView.swift
//  ArticleReader
//
//  Created by NGUYEN CHI CONG on 9/9/21.
//

import Foundation
import UIKit
import WebKit

/// Updated using open source SwiftyMercuryReady

private let htmlTemplatePath = "HTMLReader/readerTemplate"

class ReaderWebView: WKWebView, WKNavigationDelegate {
    /// Indicates if the template is loaded or not
    private(set) var initialized: Bool = false
    private var content: ReaderContent?

    /// Fills the template with a title for its content
    private func setContentTitle(title: String, completion: ((Any?, Error?) -> Void)? = nil) {
        let jsHeadline = "setHeadline(\"\(escapeHtml(title))\");"
        self.evaluateJavaScript(jsHeadline, completionHandler: completion)
    }

    /// Fills the template body
    private func setContent(body: String, completion: ((Any?, Error?) -> Void)? = nil) {
        let jsContent = "setContent(\"\(escapeHtml(body))\");"
        self.evaluateJavaScript(jsContent, completionHandler: completion)
    }

    /// Fills the template with a domain name
    private func setContentDomain(domain: String, completion: ((Any?, Error?) -> Void)? = nil) {
        let jsDomain = "setDomain(\"\(domain)\");"
        self.evaluateJavaScript(jsDomain, completionHandler: completion)
    }

    /// Fills the template with an author name
    private func setContentAuthor(author: String, completion: ((Any?, Error?) -> Void)? = nil) {
        let jsAuthor = "setAuthor(\"\(author)\");"
        self.evaluateJavaScript(jsAuthor, completionHandler: completion)
    }

    /// Fills the template with a publication date
    private func setContentDate(date: String, completion: ((Any?, Error?) -> Void)? = nil) {
        let jsDate = "setPublicationDate(\"\(date)\");"
        self.evaluateJavaScript(jsDate, completionHandler: completion)
    }

    private func setLoaderVisibility(_ visible: Bool) {
        let jsLoader = visible ? "showLoader();" : "hideLoader();"
        self.evaluateJavaScript(jsLoader, completionHandler: nil)
    }

    convenience init() {
        self.init(frame: .zero, configuration: WKWebViewConfiguration())
    }

    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        self.navigationDelegate = self

        self.reloadTemplate()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func clearData() {
        let jsClear = "clearData();"
        self.evaluateJavaScript(jsClear, completionHandler: nil)
    }

    public func load(readerContent: ReaderContent) {
        self.content = readerContent

        guard self.initialized else { return }

        let group = DispatchGroup()
        group.enter()
        self.setContentDomain(domain: readerContent.domain ?? "") { _, _ in group.leave() }
        group.enter()
        self.setContentAuthor(author: readerContent.author ?? "") { _, _ in group.leave() }
        group.enter()
        self.setContentTitle(title: readerContent.title) { _, _ in group.leave() }
        if let publishedDate = readerContent.publishedDateDisplay {
            group.enter()
            self.setContentDate(date: publishedDate) { _, _ in group.leave() }
        }
        group.enter()
        self.setContent(body: readerContent.content) { _, _ in group.leave() }
        group.notify(queue: .main) {
            self.setLoaderVisibility(false)
        }
    }

    private func initReaderCSS() {
        self.evaluateJavaScript("setSerif(1);", completionHandler: nil)
        self.evaluateJavaScript("setSize(2);", completionHandler: nil)
        self.evaluateJavaScript("setTheme(0);", completionHandler: nil)
    }

    private func reloadTemplate() {
        let htmlPath = Bundle.main.path(forResource: htmlTemplatePath, ofType: "html")
        let htmlUrl = URL(fileURLWithPath: htmlPath!, isDirectory: false)
        self.loadFileURL(htmlUrl, allowingReadAccessTo: htmlUrl)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if !self.initialized {
            self.initReaderCSS()
            self.initialized = true

            if let content = self.content {
                self.load(readerContent: content)
            }
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType != .reload, navigationAction.request.url?.scheme != "file" {
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}

private func escapeHtml(_ html: String) -> String {
    let chars: [String: String] = ["\n": "<br />",
                                   "\r": "<br />",
                                   "\t": "",
                                   "\0": "",
                                   "\"": "\\u0022"]
    var result = html
    for (target, fix) in chars {
        result = result.replacingOccurrences(of: target, with: fix)
    }
    return result
}
