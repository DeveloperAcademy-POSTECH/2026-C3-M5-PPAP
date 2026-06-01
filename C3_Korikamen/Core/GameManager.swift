//
//  GameManager.swift
//  C3_Korikamen
//
//  Created by Park on 6/2/26.
//
//  게임 전체 진행(단계 전환·경과시간)을 관리하는 두뇌.
//  진실의 원천은 GKStateMachine, phase는 SwiftUI 표시용 거울.
//

import GameplayKit
import Combine

// MARK: - 게임 단계
enum GamePhase: Equatable {
    case intro
    case stage(Int)   // 1, 2, 3
    case ending
}

// MARK: - GameManager
final class GameManager: ObservableObject {
    /// SwiftUI 표시용. 각 상태가 진입할 때 갱신된다.
    @Published private(set) var phase: GamePhase = .intro

    /// [스테이지 번호: 경과시간(초)] — 각 스테이지가 끝날 때 기록
    private(set) var stageTimes: [Int: Double] = [:]
    var totalPlayTime: Double { stageTimes.values.reduce(0, +) }

    private lazy var machine = GKStateMachine(states: [
        IntroState(self), Stage1State(self), Stage2State(self),
        Stage3State(self), EndingState(self),
    ])

    init() { machine.enter(IntroState.self) }

    /// 스테이지 종료 시 호출 (경과시간 기록)
    func recordTime(stage: Int, elapsed: Double) { stageTimes[stage] = elapsed }

    /// 현재 단계 → 다음 단계. 각 화면이 완료/클리어 시 호출.
    func advance() {
        switch phase {
        case .intro:    machine.enter(Stage1State.self)
        case .stage(1): machine.enter(Stage2State.self)
        case .stage(2): machine.enter(Stage3State.self)
        case .stage(3): machine.enter(EndingState.self)
        case .ending:   machine.enter(IntroState.self)   // 엔딩 → 처음으로(리플레이)
        case .stage:    break                            // 1~3 외(이론상 없음)
        }
    }

    /// 상태 진입 시 phase 거울 갱신. (상태 클래스 전용)
    fileprivate func updatePhase(_ newPhase: GamePhase) { phase = newPhase }
}

// MARK: - 상태(GKState): 진입 시 phase 갱신 + 다음 상태 규칙 명시
class GameBaseState: GKState {
    weak var manager: GameManager?
    init(_ manager: GameManager) { self.manager = manager; super.init() }
}

final class IntroState: GameBaseState {
    override func didEnter(from previous: GKState?) { manager?.updatePhase(.intro) }
    override func isValidNextState(_ s: AnyClass) -> Bool { s == Stage1State.self }
}
final class Stage1State: GameBaseState {
    override func didEnter(from previous: GKState?) { manager?.updatePhase(.stage(1)) }
    override func isValidNextState(_ s: AnyClass) -> Bool { s == Stage2State.self }
}
final class Stage2State: GameBaseState {
    override func didEnter(from previous: GKState?) { manager?.updatePhase(.stage(2)) }
    override func isValidNextState(_ s: AnyClass) -> Bool { s == Stage3State.self }
}
final class Stage3State: GameBaseState {
    override func didEnter(from previous: GKState?) { manager?.updatePhase(.stage(3)) }
    override func isValidNextState(_ s: AnyClass) -> Bool { s == EndingState.self }
}
final class EndingState: GameBaseState {
    override func didEnter(from previous: GKState?) { manager?.updatePhase(.ending) }
    override func isValidNextState(_ s: AnyClass) -> Bool { s == IntroState.self }
}
