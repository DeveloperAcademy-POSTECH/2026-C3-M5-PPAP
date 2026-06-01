//
//  ContentView.swift
//  C3_Korikamen
//
//  Created by Park on 6/2/26.
//
//  game.phase에 따라 화면을 전환하는 라우터.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var game: GameManager

    var body: some View {
        switch game.phase {
        case .intro:    IntroView(onContinue: game.advance)
        case .stage(1): Stage1View(onClear: game.advance)
        case .stage(2): Stage2View(onClear: game.advance)
        case .stage(3): Stage3View(onClear: game.advance)
        case .stage:    EmptyView()                        // 1~3 외(이론상 없음)
        case .ending:   EndingView(onReplay: game.advance)
        }
    }
}
