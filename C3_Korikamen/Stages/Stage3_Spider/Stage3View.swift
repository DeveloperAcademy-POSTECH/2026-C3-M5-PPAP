//
//  Stage3View.swift
//  C3_Korikamen
//
//  Created by Park on 6/2/26.
//

import SwiftUI

struct Stage3View: View {
    let onClear: () -> Void
    let onFail: () -> Void
    @StateObject private var timer = CountdownTimer(duration: 90)    // 90초 (기획값)

    var body: some View {
        VStack(spacing: 20) {
            Text("스테이지 3 · 관 열기 & 거미줄 제거").font(.largeTitle).bold()
            Text("노튼 담당 — 여기에 게임 구현").foregroundStyle(.secondary)
            Text("남은 시간: \(Int(timer.remaining))초").monospacedDigit()
            HStack {
                Button("클리어 → 다음", action: onClear).buttonStyle(.borderedProminent)
                Button("실패(테스트)", role: .destructive, action: onFail)
            }
        }
        .padding()
        .onAppear { timer.start() }
        .onChange(of: timer.isTimeOver) { _, over in if over { onFail() } }
    }
}
