//
//  ContentView.swift
//  ArticleReader
//
//  Created by NGUYEN CHI CONG on 9/9/21.
//

import Combine
import Kingfisher
import SwiftUI

struct ArticleListView: View {
    @StateObject var model = ArticleModel()

    var body: some View {
        NavigationView {
            List(model.contents) { content in
                NavigationLink(destination: ArticleDetailView(article: content)) {
                    HStack(alignment: .top, spacing: 8) {
                        KFImage(content.thumbnail)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 60)

                        VStack(alignment: .leading, spacing: 8) {
                            if let title = content.title {
                                Text(title)
                                    .font(.system(size: 17, weight: .medium, design: .default))
                            }
                            Text(content.author)
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Articles")
        }
        .progressDialog(isShowing: $model.isLoading, message: "Loading...")
        .alert(item: $model.error, content: { error in
            Alert(
                title: Text(error.title),
                primaryButton: .default(Text("Retry")) {
                    model.fetch()
                },
                secondaryButton: .cancel()
            )
        })
        .onAppear(perform: model.fetch)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ArticleListView()
        }
    }
}
