//
//  ContentView.swift
//  C3_Korikamen
//
//  Created by Park on 6/2/26.
//
//  game.phase에 따라 화면을 전환하는 라우터.
//
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var game: GameManager

    var body: some View {
        routedView
            .frame(maxWidth: .infinity, maxHeight: .infinity)   // 화면 가득 → 오버레이 기준이 '화면'
            .overlay(alignment: .bottomLeading) {               // 좌측 하단에 고정
                #if DEBUG
                MockPencilFeeder()
                #endif
            }
    }

    @ViewBuilder private var routedView: some View {
        if let failed = game.failedStage {
            FailView(stage: failed, onRetry: game.retry)
        } else {
            switch game.phase {
            case .intro:    IntroView(onContinue: game.advance)
            case .stage(1): Stage1View(onClear: game.advance, onFail: game.fail)
            case .stage(2): Stage2View(onClear: game.advance, onFail: game.fail)
            case .stage(3): Stage3View(onClear: game.advance, onFail: game.fail)
            case .stage:    EmptyView()
            case .ending:   EndingView(onReplay: game.advance)
            }
        }
    }
}
