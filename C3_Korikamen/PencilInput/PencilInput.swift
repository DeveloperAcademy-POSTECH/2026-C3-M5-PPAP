//
//  PencilInput.swift
//  C3_Korikamen
//
//  Created by Park on 6/2/26.
//
//  팀 공통 계약(Contract).
//  소비자(각 스테이지)가 의존하는 단 하나의 관찰 대상.
//  - 소비자: @EnvironmentObject var pencil: PencilInput → pencil.state.* 를 "읽기만".
//  - 생산자: RealPencilFeeder(실기기) 또는 MockPencilFeeder(시뮬레이터)가 state를 "채운다".
//    ※ Feeder는 이 파일이 아니라 4·5단계에서 추가한다.
//

import Combine

final class PencilInput: ObservableObject {
    /// 생산자(Feeder)가 갱신하고, 소비자(스테이지)가 관찰한다.
    @Published var state = PencilState()

    /// 프리뷰/테스트에서 시작 상태를 주입할 수 있게 기본값 제공.
    init(state: PencilState = PencilState()) {
        self.state = state
    }
}
