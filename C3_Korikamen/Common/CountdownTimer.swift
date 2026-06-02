//
//  CountdownTimer.swift
//  C3_Korikamen
//
//  Created by Park on 6/2/26.
//
//  공용 카운트다운 타이머. 3스테이지 전부 제한시간에 사용.
//

import Combine
import Foundation

final class CountdownTimer: ObservableObject {
    @Published private(set) var remaining: Double
    @Published private(set) var isRunning = false

    let duration: Double
    private let tick: Double
    private var cancellable: AnyCancellable?

    var elapsed: Double { duration - remaining }
    var isTimeOver: Bool { remaining <= 0 }

    init(duration: Double, tick: Double = 0.05) {   // 기본 50ms (기획서 tick과 동일)
        self.duration = duration
        self.tick = tick
        self.remaining = duration
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        cancellable = Timer.publish(every: tick, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.step() }
    }

    func stop() { isRunning = false; cancellable?.cancel(); cancellable = nil }
    func reset() { stop(); remaining = duration }

    private func step() {
        remaining = max(0, remaining - tick)
        if remaining <= 0 { stop() }   // 타임오버 → 멈춤 (스테이지가 isTimeOver 보고 onFail 처리)
    }
}
