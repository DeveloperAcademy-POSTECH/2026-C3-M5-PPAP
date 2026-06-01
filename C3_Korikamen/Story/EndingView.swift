//
//  EndingView.swift
//  C3_Korikamen
//
//  Created by Park on 6/2/26.
//

import SwiftUI

struct EndingView: View {
    let onReplay: () -> Void
    // 총 플레이타임을 보여주려면 @EnvironmentObject var game: GameManager 추가해 game.totalPlayTime 사용
    var body: some View {
        VStack(spacing: 20) {
            Text("엔딩").font(.largeTitle).bold()
            Text("엔딩 스토리 (자리표시) — 클리어 연출/크레딧 들어갈 곳")
                .foregroundStyle(.secondary)
            Button("다시하기", action: onReplay)
                .buttonStyle(.bordered)
        }
        .padding()
    }
}
