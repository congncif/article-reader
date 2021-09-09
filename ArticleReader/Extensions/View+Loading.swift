//
//  View+Loading.swift
//  ArticleReader
//
//  Created by NGUYEN CHI CONG on 9/9/21.
//

import Foundation
import SwiftUI

struct Dialog<DialogContent: View>: ViewModifier {
    @Binding var isShowing: Bool

    let cancelOnTapOutside: Bool
    let cancelAction: (() -> Void)?
    let dialogContent: DialogContent

    init(isShowing: Binding<Bool>,
         cancelOnTapOutside: Bool,
         cancelAction: (() -> Void)?,
         @ViewBuilder dialogContent: () -> DialogContent) {
        _isShowing = isShowing
        self.cancelOnTapOutside = cancelOnTapOutside
        self.cancelAction = cancelAction
        self.dialogContent = dialogContent()
    }

    func body(content: Content) -> some View {
        ZStack {
            content
            if isShowing {
                Rectangle()
                    .foregroundColor(Color.clear)
                    .onTapGesture {
                        if cancelOnTapOutside {
                            cancelAction?()
                            isShowing = false
                        }
                    }
                ZStack {
                    dialogContent.background(RoundedRectangle(cornerRadius: 8).foregroundColor(Color.black.opacity(0.4)))
                }.padding(40)
            }
        }
    }
}

extension View {
    func dialog<DialogContent: View>(isShowing: Binding<Bool>,
                                     cancelOnTapOutside: Bool = true,
                                     cancelAction: (() -> Void)? = nil,
                                     @ViewBuilder dialogContent: @escaping () -> DialogContent) -> some View {
        self.modifier(Dialog(isShowing: isShowing,
                             cancelOnTapOutside: cancelOnTapOutside,
                             cancelAction: cancelAction,
                             dialogContent: dialogContent))
    }
}

extension View {
    func progressDialog(isShowing: Binding<Bool>,
                        message: String,
                        progress: Progress = .init()) -> some View {
        self.dialog(isShowing: isShowing, cancelOnTapOutside: false) {
            HStack(spacing: 10) {
                if progress.isIndeterminate {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                } else {
                    ProgressView(value: Float(progress.completedUnitCount) / Float(progress.totalUnitCount))
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                }
                Text(message)
                    .fontWeight(.medium)
                    .foregroundColor(Color.white)
            }.padding()
        }
    }
}
