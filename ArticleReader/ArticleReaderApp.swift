//
//  ArticleReaderApp.swift
//  ArticleReader
//
//  Created by NGUYEN CHI CONG on 9/9/21.
//

import SwiftUI

@main
struct ArticleReaderApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ArticleListView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        ServiceRegistry.initialize()
            .register { ArticleProvider() }.implements(ArticleService.self)
            .next()
            .register { ReaderParser() }.implements(ReaderParseService.self)

        return true
    }
}
