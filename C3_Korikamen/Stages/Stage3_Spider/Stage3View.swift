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
    @EnvironmentObject private var pencil: PencilInput //펜슬 입력
    @StateObject private var manager = Stage3GameManager() // 로직 클래스 불러오기
    
    
    // 임시 세로 게이지 바 (테스트용)
    private var gauageBar : some View {
        GeometryReader { geo in // 막대가 차지하는 실제 크기를 알기 위해 사용
            let h = geo.size.height
            ZStack(alignment:.bottom) {
                RoundedRectangle(cornerRadius: 8) // 배경
                    .fill(Color.gray.opacity(0.2))
                
                Rectangle() // 목표 범위 띠(초록색)
                    .fill(Color.green.opacity(0.3))
                    .frame(height: h * (manager.targetMax - manager.targetMin))
                    .offset(y: -h * manager.targetMin)
                
                RoundedRectangle(cornerRadius: 8)// 현재 게이지(노란색으로)
                    .fill(Color.yellow)
                    .frame(height: h * manager.gauge) //게이지 비율만큼 표현
            }
            
        }
        .frame(width: 40, height: 300)
    }
    var body: some View {
        VStack(spacing: 20) {
            Text("스테이지 3 · 관 열기 & 거미줄 제거").font(.largeTitle).bold()
            Text("노튼 담당 — 여기에 게임 구현").foregroundStyle(.secondary)
            Text("남은 시간: \(Int(timer.remaining))초").monospacedDigit()
            gauageBar // 게이지바 추가
            Text("게이지: \(Int(manager.gauge * 100))%")
            Text("성공: \(manager.successCount)/\(manager.requiredSuccessCount)   거미줄: \(manager.webLayerIndex)겹")
            
            
            HStack {
                Button("클리어 → 다음", action: onClear).buttonStyle(.borderedProminent)
                Button("실패(테스트)", role: .destructive, action: onFail)
            }
            
        }
        .padding()
        .onAppear { timer.start() }
        .onChange(of: timer.isTimeOver) { _, over in if over { onFail() } }
        
        // 스퀴즈 상태에 따라 맞는 함수를 부를 수 있도록 추가
        .onChange(of: pencil.state.squeezePhase){ _, phase in
            switch phase {
            case .began, .changed: manager.beginSqueeze() // 스퀴즈 시작 + 누르기 : 게이지 증가 시작
            case .ended: manager.endSqueeze() // 스퀴즈 종료 -> 판정
            case .none: break // ignore
            }
        }
        .onChange(of: manager.isCleared) {_,cleared in
            if cleared {
                timer.stop() // 제한시간 타이머 정지
                onClear() // 다음 단계(엔딩씬)로
            }
        }
        .sensoryFeedback(.success, trigger: manager.successCount)   // 성공 시 햅틱 피드백 -> mock 대체 후 판단 가능할 듯

    }
}

