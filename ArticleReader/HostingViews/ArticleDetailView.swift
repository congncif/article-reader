//
//  ArticleDetailView.swift
//  ArticleReader
//
//  Created by NGUYEN CHI CONG on 9/9/21.
//

import SwiftUI

enum ContentMode: String, CaseIterable {
    case web = "Web"
    case reader = "Reader"
}

struct ArticleDetailView: View {
    @State var progress: Double = 0
    @State var selectedMode: ContentMode = .web
    @StateObject var model = ReaderParseModel()

    let article: Article

    private let modes = ContentMode.allCases

    var body: some View {
        VStack(alignment: .leading) {
            if progress < 1 {
                LineProgressView(value: $progress).frame(height: 1)
            }

            switch selectedMode {
            case .web:
                WebView(
                    progress: $progress,
                    url: article.url
                )
            case .reader:
                if let content = model.content {
                    ReaderView(progress: $progress, content: content)
                } else {
                    Spacer()
                    HStack(alignment: .center, spacing: 8) {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
        .navigationBarTitle(Text(""), displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Picker(
                    selection: $selectedMode,
                    label: Text("Content Mode")
                ) {
                    ForEach(modes, id: \.self) {
                        Text($0.rawValue)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: selectedMode) { mode in
                    switch mode {
                    case .reader:
                        model.parse(contentOf: article)
                    case .web:
                        break
                    }
                }
            }
        }
        .alert(item: $model.error, content: { error in
            Alert(
                title: Text(error.title),
                primaryButton: .default(Text("Retry")) {
                    model.parse(contentOf: article)
                },
                secondaryButton: .cancel()
            )
        })
        .onAppear(perform: {
            // Preload for reader mode
            model.parse(contentOf: article)
        })
    }
}
