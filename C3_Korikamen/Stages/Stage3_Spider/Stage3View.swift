//
//  Stage3View.swift
//  C3_Korikamen
//
//  Created by Park on 6/2/26.
//

import SwiftUI

struct Stage3View: View {
    let onClear: () -> Void
    var body: some View {
        VStack(spacing: 20) {
            Text("스테이지 3 · 거미줄 제거").font(.largeTitle).bold()
            Text("노튼 담당 — 여기에 게임 구현 (지금은 빈 자리표시)")
                .foregroundStyle(.secondary)
            Button("클리어 → 다음", action: onClear)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
