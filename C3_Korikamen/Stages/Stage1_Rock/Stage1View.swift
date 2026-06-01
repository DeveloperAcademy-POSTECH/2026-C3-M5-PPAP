//
//  Stage1View.swift
//  C3_Korikamen
//
//  Created by Park on 6/2/26.
//

import SwiftUI

struct Stage1View: View {
    /// 클리어 시 호출(다음 단계로). ContentView가 주입.
    let onClear: () -> Void
    var body: some View {
        VStack(spacing: 20) {
            Text("스테이지 1 · 관 돌 부수기").font(.largeTitle).bold()
            Text("맥스 담당 — 여기에 게임 구현 (지금은 빈 자리표시)")
                .foregroundStyle(.secondary)
            Button("클리어 → 다음", action: onClear)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
