//
//  Stage2View.swift
//  C3_Korikamen
//
//  Created by Park on 6/2/26.
//

import SwiftUI

struct Stage2View: View {
    let onClear: () -> Void
    var body: some View {
        VStack(spacing: 20) {
            Text("스테이지 2 · 관 자물쇠 따기").font(.largeTitle).bold()
            Text("실라 담당 — 여기에 게임 구현 (지금은 빈 자리표시)")
                .foregroundStyle(.secondary)
            Button("클리어 → 다음", action: onClear)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
