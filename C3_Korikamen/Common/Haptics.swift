//
//  Haptics.swift
//  C3_Korikamen
//
//  공용 햅틱. 3스테이지 공통으로 간단히 쓴다.
//  iPad는 본체 진동모터가 없어 UIKit 임팩트 햅틱이 무음이다.
//  → SwiftUI sensoryFeedback의 .alignment / .pathComplete 를 쓰면
//    시스템이 Apple Pencil Pro로 라우팅한다. (iOS 17.5+, 펜이 화면에 닿은 순간에만)
//
//  사용법:
//   1) 스테이지 루트 뷰:  @StateObject private var haptics = Haptics()
//   2) 그 뷰에 부착:       .stageHaptics(haptics)
//   3) 펜이 닿아있는 흐름(씬 interact 등)에서:  haptics.tap() / haptics.pulse()
//

import SwiftUI
import Combine
import QuartzCore

final class Haptics: ObservableObject {

    /// 짧고 가벼운 틱. (드릴 연속)
    @Published private(set) var alignmentTick = 0
    /// 조금 더 또렷한 한 방. (끌 타격)
    @Published private(set) var pathTick = 0

    private var lastPulse: TimeInterval = 0   // 마지막 pulse 발동 시각(주기 조절용)

    /// 단발 진동 1회. (끌 타격 등)
    func tap() { pathTick &+= 1 }

    /// 빠른 주기 진동. 매 프레임 호출해도 interval(초) 간격으로만 실제 발동.
    /// (펜슬 프로는 20ms 이하 간격을 하나로 묶으므로 0.05 권장)
    func pulse(interval: TimeInterval = 0.05) {
        let now = CACurrentMediaTime()
        guard now - lastPulse >= interval else { return }
        lastPulse = now
        alignmentTick &+= 1
    }
}

extension View {
    /// 스테이지 공통 햅틱 출력. Haptics 트리거가 바뀌면 펜슬 프로 햅틱 발동.
    func stageHaptics(_ haptics: Haptics) -> some View {
        self
            .sensoryFeedback(.alignment, trigger: haptics.alignmentTick)
            .sensoryFeedback(.pathComplete, trigger: haptics.pathTick)
    }
}
