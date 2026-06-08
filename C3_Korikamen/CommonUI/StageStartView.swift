//
//  StageStartView.swift
//  C3_Korikamen
//
//  Created by Park on 6/8/26.
//

import SwiftUI

/// 스테이지 진입 게이트: 시작화면 → (탭) 튜토리얼 겹침 → (탭) 실제 게임.
/// 게임 콘텐츠는 .playing 단계에서야 생성되므로 타이머 등은 그때 시작된다.
struct StageStartView<Content: View>: View {
    let titleImage: String        // 스테이지 시작화면 이미지
    let tutorialImage: String     // 시작화면 위에 겹쳐질 튜토리얼 이미지
    @ViewBuilder var content: () -> Content   // 실제 게임 뷰

    private enum Phase { case title, tutorial, playing }
    @State private var phase: Phase = .title

    var body: some View {
        if phase == .playing {
            content()                                   // 실제 게임 (탭 가로채지 않음)
        } else {
            ZStack {
                Image(titleImage)                       // 시작화면
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                if phase == .tutorial {                 // 시작화면 위에 튜토리얼 겹치기
                    Color.black.opacity(0.35).ignoresSafeArea()
                    VStack {
                        Spacer()
                        Image(tutorialImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                    }
                    .ignoresSafeArea(edges: .bottom)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                switch phase {
                case .title:    withAnimation(.easeInOut(duration: 0.25)) { phase = .tutorial }
                case .tutorial: phase = .playing        // 두 번째 탭 → 게임 시작
                case .playing:  break
                }
            }
        }
    }
}
