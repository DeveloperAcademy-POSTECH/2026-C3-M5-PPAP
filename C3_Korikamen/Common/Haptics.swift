//
//  Haptics.swift
//  C3_Korikamen
//
//  Created by Park on 6/8/26.
//
//  공용 햅틱 피드백. 3스테이지 공통으로 간단히 호출해서 쓴다.
//  - tap()   : 단발 진동 1회. (끌 타격, 버튼 성공 등)
//  - pulse() : 빠른 주기 진동. 누르는 동안 매 프레임 호출해도
//              내부에서 interval 간격으로만 실제 진동시킨다. (드릴 연속 진동)
//

import UIKit

final class Haptics {

    /// 공용 단일 인스턴스. 스테이지에서 Haptics.shared.* 로 호출.
    static let shared = Haptics()

    // 스타일별 제너레이터를 미리 만들어 재사용(매번 생성 시 첫 진동 지연 방지).
    private var impactGenerators: [UIImpactFeedbackGenerator.FeedbackStyle: UIImpactFeedbackGenerator] = [:]
    private var lastPulse: TimeInterval = 0   // 마지막 pulse 진동 시각(주기 조절용)

    private init() {
        for style: UIImpactFeedbackGenerator.FeedbackStyle in [.light, .medium, .heavy, .rigid, .soft] {
            impactGenerators[style] = UIImpactFeedbackGenerator(style: style)
        }
    }

    private func generator(_ style: UIImpactFeedbackGenerator.FeedbackStyle) -> UIImpactFeedbackGenerator {
        impactGenerators[style] ?? UIImpactFeedbackGenerator(style: style)
    }

    /// 단발 진동 1회. (intensity 0~1)
    func tap(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium, intensity: CGFloat = 1.0) {
        let gen = generator(style)
        gen.prepare()
        gen.impactOccurred(intensity: intensity)
    }

    /// 빠른 주기 진동. 누르는 동안 매 프레임 호출해도 interval(초) 간격으로만 실제 진동.
    /// 드릴처럼 "계속 호출되는" 곳에서 부담 없이 쓰기 위한 용도.
    func pulse(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light,
               interval: TimeInterval = 0.05,
               intensity: CGFloat = 0.7) {
        let now = CACurrentMediaTime()
        guard now - lastPulse >= interval else { return }
        lastPulse = now
        tap(style, intensity: intensity)
    }
}
