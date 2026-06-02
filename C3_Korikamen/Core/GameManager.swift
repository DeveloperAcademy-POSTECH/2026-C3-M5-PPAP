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

enum GamePhase: Equatable {
    case intro
    case stage(Int)   // 1, 2, 3
    case ending
}

final class GameManager: ObservableObject {
    @Published private(set) var phase: GamePhase = .intro
    /// nil이 아니면 해당 스테이지 실패 화면 표시 (재시도 대상)
    @Published private(set) var failedStage: Int? = nil

    private(set) var stageTimes: [Int: Double] = [:]
    var totalPlayTime: Double { stageTimes.values.reduce(0, +) }

    private lazy var machine = GKStateMachine(states: [
        IntroState(self), Stage1State(self), Stage2State(self),
        Stage3State(self), EndingState(self),
    ])

    init() { machine.enter(IntroState.self) }

    func recordTime(stage: Int, elapsed: Double) { stageTimes[stage] = elapsed }

    /// 성공 → 다음 단계
    func advance() {
        switch phase {
        case .intro:    machine.enter(Stage1State.self)
        case .stage(1): machine.enter(Stage2State.self)
        case .stage(2): machine.enter(Stage3State.self)
        case .stage(3): machine.enter(EndingState.self)
        case .ending:   machine.enter(IntroState.self)
        case .stage:    break
        }
    }

    /// 현재 스테이지 실패 → 실패 화면
    func fail() { if case .stage(let n) = phase { failedStage = n } }

    /// 실패 화면에서 재시도 → 같은 스테이지 처음부터 (뷰가 새로 마운트되며 리셋)
    func retry() { failedStage = nil }

    fileprivate func updatePhase(_ newPhase: GamePhase) { phase = newPhase }
}

// MARK: - 상태(GKState) — Step 3과 동일
class GameBaseState: GKState {
    weak var manager: GameManager?
    init(_ manager: GameManager) { self.manager = manager; super.init() }
}
final class IntroState: GameBaseState {
    override func didEnter(from p: GKState?) { manager?.updatePhase(.intro) }
    override func isValidNextState(_ s: AnyClass) -> Bool { s == Stage1State.self }
}
final class Stage1State: GameBaseState {
    override func didEnter(from p: GKState?) { manager?.updatePhase(.stage(1)) }
    override func isValidNextState(_ s: AnyClass) -> Bool { s == Stage2State.self }
}
final class Stage2State: GameBaseState {
    override func didEnter(from p: GKState?) { manager?.updatePhase(.stage(2)) }
    override func isValidNextState(_ s: AnyClass) -> Bool { s == Stage3State.self }
}
final class Stage3State: GameBaseState {
    override func didEnter(from p: GKState?) { manager?.updatePhase(.stage(3)) }
    override func isValidNextState(_ s: AnyClass) -> Bool { s == EndingState.self }
}
final class EndingState: GameBaseState {
    override func didEnter(from p: GKState?) { manager?.updatePhase(.ending) }
    override func isValidNextState(_ s: AnyClass) -> Bool { s == IntroState.self }
}
