//
//  IntroView.swift
//  C3_Korikamen
//
//  Created by Park on 6/2/26.
//

import SwiftUI

struct IntroView: View {
    let onContinue: () -> Void
    var body: some View {
        VStack(spacing: 20) {
            Text("이집트 투탕카멘 유물 도굴").font(.largeTitle).bold()
            Text("인트로 스토리 (자리표시) - 스토리 컷신 들어갈 곳")
                .foregroundStyle(.secondary)
            Button("시작하기", action: onContinue)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
