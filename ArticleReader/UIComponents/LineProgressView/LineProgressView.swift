//
//  LineProgressView.swift
//  ArticleReader
//
//  Created by NGUYEN CHI CONG on 9/9/21.
//

import SwiftUI

struct LineProgressView: View {
    @Binding var value: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.2)
                    .foregroundColor(Color(.gray))

                Rectangle().frame(width: min(CGFloat(value) * geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(Color(.systemBlue))
                    .animation(.linear)
            }
        }
    }
}
