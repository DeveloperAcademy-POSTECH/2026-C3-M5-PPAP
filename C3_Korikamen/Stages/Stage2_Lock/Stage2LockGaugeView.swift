//
//  Stage2LockGaugeView.swift
//  C3_Korikamen
//
//  Created by Yourim on 6/4/26.
//

import Combine
import CoreGraphics
import SwiftUI

struct LockGaugeView: View {
    @EnvironmentObject private var pencil: PencilInput      // 펜슬 입력

    @State private var tiltRangeLower = 35.0        // 목표 Tilt 범위(Lower)
    @State private var tiltRangeUpper = 55.0        // 목표 Tilt 범위(Upper)
    @State private var rollRangeLower = 160.0       // 목표 Barrel Roll 범위(Lower)
    @State private var rollRangeUpper = 200.0       // 목표 Barrel Roll 범위(Upper)
    @State private var hapticFalloff = 12.0         // 햅틱 강도(추후 삭제예정 - 어느 정도가 적당한지 테스트 위함)
    @State private var holdDuration = 0.0           // 유지시간
    @State private var lastHoldTick: Date?          // 바로 직전에 시간을 쟀던 과거의 타이머 시점
    @State private var isClear = false              // 클리어 여부

    var holdGoal: Double = 3.0          // 목표 유지시간(기획 시 3초)
    var onClear: (() -> Void)?
    
    // 유지시간 시간 재는 타이머 - 0.05틱마다 메인 쓰레드에 현재 시각 신호를 보내주는 타이머
    private let holdticker = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { proxy in       // 현재 화면 크기 알려주는 역할(부모 뷰에 따라 자식 뷰 결정)
            landscapeLayout(size: proxy.size)       // 가로모드 기준
        }
        .onReceive(holdticker) { date in    // holdticker로부터 신호가 오면
            updateHoldProgress(at: date)    // 현재 시각(date)을 받아서 updateHoldProgress 실행(3초 버티는지 검사)
        }
        // 목표 범위가 바뀌는 경우 유지시간 리셋
        .onChange(of: tiltRangeLower) { _, _ in resetChallenge() }
        .onChange(of: tiltRangeUpper) { _, _ in resetChallenge() }
        .onChange(of: rollRangeLower) { _, _ in resetChallenge() }
        .onChange(of: rollRangeUpper) { _, _ in resetChallenge() }
    }

    private func landscapeLayout(size: CGSize) -> some View {
        let canvasWidth = min(size.width * 0.48, 520)

        return HStack(alignment: .top, spacing: 18) {
            gaugePanel      // 목표와 현재 Tilt/Barrel Roll값 확인 가능한 패널
            
            PencilStateCanvas(state: pencil.state)      // 실제 펜슬을 접촉시키는 캔버스
                .frame(width: canvasWidth)
        }
        .padding(20)
    }

    private var gaugePanel: some View {     // 목표와 현재 Tilt/Barrel Roll값 확인 가능한 패널
        VStack(alignment: .leading, spacing: 14) {
//            header      // 제목이랑 목표 써있는 용도. 추후 삭제 예정(테스트 시 가독성을 위해 사용)

            ProgressView(value: holdDuration, total: holdGoal)      // 유지시간 게이지(프로그레스바) - 디자인 변경 예정
                .tint(isClear ? .green : .orange)
                .scaleEffect(x: 1, y: 2, anchor: .center)
                .padding(.vertical, 6)

            VStack(spacing: 12) {       // Tilt, Barrel Roll 원형 게이지
                PencilRangeGauge(
                    title: "Tilt",      // 타이틀은 추후 더 쉬운 이름으로 변경 예정(피그마 참고)
                    value: pencil.state.tiltDegrees,        // Tilt 현재 값
                    isSatisfied: tiltRangeSatisfied,        // 목표 Tilt 범위에 현재 tilt가 들어가있는가
                    targetLower: min(tiltRangeLower, tiltRangeUpper),
                    targetUpper: max(tiltRangeLower, tiltRangeUpper),
                    gaugeRange: 0...90,     // Tilt 범위는 0도~90도
                    color: .teal
                )

                PencilRangeGauge(
                    title: "Barrel Roll",       // 타이틀은 추후 더 쉬운 이름으로 변경 예정(피그마 참고)
                    value: pencil.state.barrelRollDegrees,
                    isSatisfied: rollRangeSatisfied,
                    targetLower: NormalizedDegrees(rollRangeLower),
                    targetUpper: NormalizedDegrees(rollRangeUpper),
                    gaugeRange: 0...360,        // Barrel Roll 범위는 0도~360도
                    color: .indigo
                )
            }
            .frame(maxHeight: .infinity)

//            HStack(alignment: .bottom) {        // 유지 시간(상단 프로그레스바와 동일 기능 - 추후 삭제 예정)
//                VStack(alignment: .leading, spacing: 4) {
//                    Text("유지 시간")
//                        .font(.subheadline)
//                        .foregroundStyle(.secondary)
//                    Text("\(holdDuration, format: .number.precision(.fractionLength(1)))/\(holdGoal, format: .number.precision(.fractionLength(0)))s")
//                        .font(.system(size: 34, weight: .bold, design: .rounded))
//                        .monospacedDigit()
//                }
//
//                Spacer()
//            }

//            controls        // 범위 조작하는 패널(테스트 시 사용, 추후 삭제 예정)
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8))
    }

//    private var header: some View {     // 제목이랑 목표 써있는 용도. 추후 삭제 예정(테스트 시 가독성을 위해 사용)
//        VStack(alignment: .leading, spacing: 4) {
//            Text(isClear ? "Clear" : "Lockpick Hold")
//                .font(.system(size: 26, weight: .semibold, design: .rounded))
//                .foregroundStyle(isClear ? .green : .primary)
//            Text("Tilt와 Barrel Roll을 목표 범위 안에 \(Int(holdGoal))초 유지")
//                .font(.subheadline)
//                .foregroundStyle(.secondary)
//        }
//    }

//    private var controls: some View {       // 범위 조작하는 패널(테스트 시 사용, 추후 삭제 예정)
//        VStack(spacing: 8) {
//            HStack(spacing: 14) {       // Tilt 범위 조절
//                PencilRangeSlider(title: "Tilt Min", value: $tiltRangeLower, range: 0...90)
//                PencilRangeSlider(title: "Tilt Max", value: $tiltRangeUpper, range: 0...90)
//            }
//
//            HStack(spacing: 14) {       // Barrel Roll 범위 조절, 햅틱 빈도 조절
//                PencilRangeSlider(title: "Roll Min", value: $rollRangeLower, range: 0...360)
//                PencilRangeSlider(title: "Roll Max", value: $rollRangeUpper, range: 0...360)
//                PencilRangeSlider(title: "Falloff", value: $hapticFalloff, range: 3...30)
//            }
//        }
//        .padding(12)
//        .background(Color(uiColor: .tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 8))
//    }

    private var tiltRangeSatisfied: Bool {      // PencilRangeGauge에서 범위를 만족했는지 확인하는 용도로 사용(Tilt)
        // tiltRangeLower, tiltRangeUpper 이름에 상관없이 설정된 두 변수 중 작은 값을 범위의 최솟값, 큰 값을 범위의 최댓값으로 설정
        let lower = min(tiltRangeLower, tiltRangeUpper)
        let upper = max(tiltRangeLower, tiltRangeUpper)
        
        // 현재 Tilt가 범위 사이인지 판단하여 return
        return pencil.state.tiltDegrees >= lower && pencil.state.tiltDegrees <= upper
    }

    private var rollRangeSatisfied: Bool {      // PencilRangeGauge에서 범위를 만족했는지 확인하는 용도로 사용(Barrel Roll)
        CircularRangeContains(      // Barrel Roll 목표 범위에 현재 값이 있으면 true를 반환하는 함수
            value: pencil.state.barrelRollDegrees,
            lower: rollRangeLower,
            upper: rollRangeUpper
        )
    }
    
    // 시간을 누적하고 3초 버텼는지 검사하는 함수
    private func updateHoldProgress(at date: Date) {
        defer { lastHoldTick = date }       // 함수 끝날 때 lastHoldTick을 date로 업데이트

        guard tiltRangeSatisfied && rollRangeSatisfied else {    // tilt/roll이 하나라도 범위 만족 못하는경우(false)
            resetChallenge(keepingTick: true)
            return
        }
        
        // lastHoldTick이 nil인 경우 탈출(과거 기록이 없는 경우 기준점이 없으니 함수 종료)
        guard let lastHoldTick else { return }
        
        // lastHoldTick부터 지금까지 실제로 얼마나 흘렀는가(초 단위 계산)
        // 오류 방지를 위해 흘러간 시간은 0초~0.2초 사이로만 인정
        let delta = min(max(date.timeIntervalSince(lastHoldTick), 0), 0.2)
        holdDuration = min(holdGoal, holdDuration + delta)
        
        // 목표시간, 지금까지 버틴 시간 + 흘러간 시간 중 최솟값을 holdDuration에 저장
        if holdDuration >= holdGoal && !isClear {
            isClear = true
            onClear?()
        }
    }
    
    // 범위 벗어나는 경우 유지시간 리셋
    private func resetChallenge(keepingTick: Bool = false) {
        holdDuration = 0        // 유지시간 -> 0
        isClear = false         // 성공 판정 -> false

        if !keepingTick {
            lastHoldTick = nil      // 시간 기준점을 nil로 설정
        }
    }
}

struct PencilStateCanvas: View {        // 실제 펜슬을 접촉시키는 캔버스
    let state: PencilState

    var body: some View {       // 캔버스 디자인은 추후 수정 예정(Hi-Fi)
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(uiColor: .systemGroupedBackground))

                Canvas { context, size in
                    var path = Path()
                    let spacing: CGFloat = 48
                    
//                    // 격자무늬
//                    stride(from: CGFloat(0), through: size.width, by: spacing).forEach { x in
//                        path.move(to: CGPoint(x: x, y: 0))
//                        path.addLine(to: CGPoint(x: x, y: size.height))
//                    }
//
//                    stride(from: CGFloat(0), through: size.height, by: spacing).forEach { y in
//                        path.move(to: CGPoint(x: 0, y: y))
//                        path.addLine(to: CGPoint(x: size.width, y: y))
//                    }
//
//                    context.stroke(path, with: .color(.secondary.opacity(0.22)), lineWidth: 1)
                }

                if let location = state.location {      // nil 탈출(좌표 없는 경우)
                    // 캔버스 범위를 벗어날 경우 0~캔버스 가로/세로길이 사이로 강제로 만드는 안전장치
                    pencilMarker(at: clamped(location, in: geometry.size))
                }
            }
//            .overlay(alignment: .topLeading) {
//                // 화면에 접촉하고 있는 경우/호버/둘다 아닌 경우 표시 - 테스트 시 사용, 추후 삭제 혹은 변경 예정
//                Text(state.isTouching ? "Touch" : (state.isHovering ? "Hover" : "Waiting"))
//                    .font(.subheadline)
//                    .foregroundStyle(.secondary)
//                    .padding(12)
//            }
        }
    }
    
    // Mock으로 펜슬을 테스트하는 경우 현재 위치/Tilt/Barrel Roll을 간접적으로 표시하기 위한 마커 - 테스트 시 사용
    private func pencilMarker(at point: CGPoint) -> some View {
        ZStack {
            Circle()
                .fill(.teal.opacity(0.16))
                .frame(width: 76, height: 76)

            Capsule()
                .fill(.teal)
                .frame(width: 12, height: 42 + CGFloat(state.tiltDegrees))
                .offset(y: -(21 + CGFloat(state.tiltDegrees) / 2))

            RoundedRectangle(cornerRadius: 4)
                .fill(.indigo)
                .frame(width: 112, height: 26)
                .overlay(alignment: .trailing) {
                    Circle()
                        .fill(.orange)
                        .frame(width: 14, height: 14)
                        .padding(.trailing, 12)
                }
                .rotationEffect(.degrees(state.barrelRollDegrees))

            Circle()
                .fill(.primary)
                .frame(width: 12, height: 12)
        }
        .position(point)
    }
    
    // 캔버스 범위를 벗어날 경우 0~캔버스 가로/세로길이 사이로 강제로 만드는 안전장치
    private func clamped(_ point: CGPoint, in size: CGSize) -> CGPoint {
        CGPoint(
            x: min(max(point.x, 0), size.width),
            y: min(max(point.y, 0), size.height)
        )
    }
}

// 원형으로 게이지 나타내는 뷰
// 내 점수가 전체에서 몇 %인지 계산 (0에서 1 사이의 값으로 변환)
// 그 %만큼 화면에 동그란 호(Arc) 그리기

struct PencilRangeGauge: View {
    let title: String       // 어떤 게이지인지 나타내는 타이틀
    let value: Double       // 현재 입력받는 펜슬 값(Tilt, Barrel Roll)
    let isSatisfied: Bool       // 목표 범위 안에 현재 입력값이 들어가있는지 여부
    let targetLower: Double     // 목표 범위(Lower)
    let targetUpper: Double     // 목표 범위(Upper)
    let gaugeRange: ClosedRange<Double>     // 게이지 범위(Tilt : 0~90, Barrel Roll : 0~360)
    let color: Color        // 게이지 색상

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                // tilte / 목표 범위에 들어가있는지에 따른 시각적 피드백(아이콘) - 추후 방식 수정할 예정(Hi-fi 참고)
                Label(title, systemImage: isSatisfied ? "checkmark.circle.fill" : "xmark.circle")
                    .font(.headline)
                    .foregroundStyle(isSatisfied ? .green : .primary)
                Spacer()
//                Text("\(Int(value.rounded()))deg")      // 현재 입력값 숫자로 나타내는 용도(테스트에만 사용)
//                    .font(.title3.weight(.bold))
//                    .monospacedDigit()
            }

            ZStack {        // 원형 게이지 표시
                Circle()        // 범위 밑에 깔리는 원 테두리
                    .stroke(.quaternary, lineWidth: 16)

                rangeArc    // 목표 범위를 시각적으로 보여주는 역할(범위만 주황색으로 표시)

                PencilGaugeNeedle(angle: valueAngle, color: color)

                Circle()
                    .fill(color)
                    .frame(width: 12, height: 12)
            }
            .aspectRatio(1, contentMode: .fit)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 8))
    }
    
    // 현재 펜슬값(value)이 전체 범위에서 어디쯤(%) 있는지를 구해서 나중에 바늘(valueAngle)을 돌릴 때 쓰려고 만든 것
    private var progress: CGFloat {     // 실제 펜슬 데이터 -> 비율(0~1)
        let span = gaugeRange.upperBound - gaugeRange.lowerBound        // 총 길이(큰값-작은값)
        return lockpickClamped(     // 범위를 벗어나도 0~1 사이로 강제로 만드는 안전장치
            CGFloat((value - gaugeRange.lowerBound) / span),
            lower: 0,
            upper: 1
        )
    }
    
    // 현재 값을 나타내는 바늘에 사용(PencilGaugeNeedle)
    private var valueAngle: Angle {     // 비율 -> 각도로 다시 바꾸는 역할
        .degrees(Double(progress) * 360)
    }
    
    // 범위를 시각적으로 보여주는 역할 - Barrel Roll 목표 범위가 360도를 넘어가는 예외 상황 처리 포함
    // trim 사용 - 원의 일부분만 잘라서 보여준다
    @ViewBuilder
    private var rangeArc: some View {
        let lower = rangeProgress(for: targetLower)     // 실제 값 -> 비율
        let upper = rangeProgress(for: targetUpper)

        if lower <= upper {     // 일반적인 경우(lower가 작은 경우)
            Circle()        // 원을 그린 후 trim으로 일부만 잘라 보여주는 방식
                .trim(from: lower, to: upper)
                .stroke(.orange, style: StrokeStyle(lineWidth: 18, lineCap: .round))
                .rotationEffect(.degrees(-90))
        } else {        // lower가 upper보다 큰 경우(원이 한 바퀴 넘어가는 경우)
            Circle()
                .trim(from: lower, to: 1)
                .stroke(.orange, style: StrokeStyle(lineWidth: 18, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Circle()
                .trim(from: 0, to: upper)
                .stroke(.orange, style: StrokeStyle(lineWidth: 18, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
    
    // 목표 범위의 시작(targetLower), 끝(targetUpper)가 각각 몇 % 지점인지 구해서 trim에 넘겨주려고 만든 것(현재 펜슬값 X)
    // 실제 값 -> 비율 trim은 0~1 사이 값만 받기 때문에 사용
    private func rangeProgress(for value: Double) -> CGFloat {
        let span = gaugeRange.upperBound - gaugeRange.lowerBound
        return lockpickClamped(
            CGFloat((value - gaugeRange.lowerBound) / span),
            lower: 0,
            upper: 1
        )
    }
}

struct PencilGaugeNeedle: View {        // 실제 펜슬 입력값을 바늘로 원형 게이지에 표현하는 뷰
    let angle: Angle        // valueAngle - 현재 펜슬의 각도 값을 받아올 예정
    let color: Color        // 바늘 색

    var body: some View {
        GeometryReader { geometry in
            // 화면의 가로 길이와 세로 길이 중 더 짧은 쪽을 기준(side)으로 설정 - (바늘 길이, 원 크기 설정을 위함)
            let side = min(geometry.size.width, geometry.size.height)
            Capsule()       // 끝이 둥근 직사각형으로 바늘 생성
                .fill(color)
                .frame(width: 6, height: side * 0.42)       // 두께 : 6, 길이 : 전체 원 크기*0.42
                // 가로는 화면 정중앙에, 세로는 정중앙에서 바늘 길이의 절반만큼 위로 올린 위치에 배치(바늘 끝이 중앙에 오도록)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2 - side * 0.21)
                .rotationEffect(angle, anchor: .center)     // 입력 각도에 따라 바늘 회전
        }
    }
}

//struct PencilRangeSlider: View {        // 목표 범위 조작하는 슬라이더 틀(추후 삭제 예정)
//    let title: String
//    @Binding var value: Double
//    let range: ClosedRange<Double>
//
//    var body: some View {
//        HStack(spacing: 12) {
//            Text(title)
//                .frame(width: 74, alignment: .leading)
//            Slider(value: $value, in: range)
//            Text("\(Int(value.rounded()))")
//                .monospacedDigit()
//                .frame(width: 38, alignment: .trailing)
//        }
//    }
//}

private func NormalizedDegrees(_ value: Double) -> Double {     // 정규화 - 360도 이상 각도를 360도 이하로 변환
    // truncatingRemainder(Double type 나머지 구하는 방법) - 360으로 나눴을 때 나머지
    let degrees = value.truncatingRemainder(dividingBy: 360)
    // 나머지가 0 이상인가? - true면 그대로, 아니면 +360을 해서 return(음수 각도 양수로 변환)
    return degrees >= 0 ? degrees : degrees + 360
}

// 정규화 : 400도, -90도 등 복잡한 숫자를 0~360도 사이로 각도 변환
private func CircularRangeContains(value: Double, lower: Double, upper: Double) -> Bool {
    let normalizedValue = NormalizedDegrees(value)      // 현재 각도 정규화
    let normalizedLower = NormalizedDegrees(lower)      // 목표 범위 최솟값 정규화
    let normalizedUpper = NormalizedDegrees(upper)      // 목표 범위 최댓값 정규화

    if normalizedLower <= normalizedUpper {     // 범위 시작 각도 <= 범위 끝 각도(일반적 경우)
        // 범위 시작 각도 <= 현재 각도 <= 범위 끝 각도 ; 범위 사이에 있으면 true 반환
        return normalizedValue >= normalizedLower && normalizedValue <= normalizedUpper
    }
    
    // 원이 끊기는 지점을 넘어간 경우(범위 시작 각도 >= 범위 끝 각도)
    // 예시 : 시작 300도 - 끝 60도일 경우
    // 시작 300 ~ (360) 사이 or (0) ~ 끝 60 사이에 현재 값이 있으면 true 반환
    return normalizedValue >= normalizedLower || normalizedValue <= normalizedUpper
}

private func lockpickClamped<T: Comparable>(_ value: T, lower: T, upper: T) -> T {
    min(max(value, lower), upper)       // 펜슬 값이 범위를 벗어나도 0~1 사이로 강제로 만드는 안전장치
}
