//
//  CommonComponents.swift
//  C3_Korikamen
//
//  Created by 이환훈 on 6/5/26.
//  해당 파일에는 저희가 공통적으로 관리해야 할 컴포넌트를 넣으면 됩니다!
// 사용시 : TimerHUDView(remaining: 스테이지별 시간 , tint: .색, imageName: "올린 이미지이름")

import Foundation
import SwiftUI

//타이머 컴포넌트

struct TimerHUDView: View {
    let remaining : Double
    var tint: Color
    var imageName: String
    
    // 초 → "분:초" 형식 (예: 90 → "1:30")
    private func timeText(_ seconds: Int) -> String {
        let m = seconds / 60          // 분
        let s = seconds % 60          // 초
        return String(format: "%d:%02d", m, s)   // 1:05 처럼 초는 두 자리
       }
    
    var body: some View {
        ZStack{
            Image("Stage3tTimer")
                .resizable()
                .frame(width: 200, height: 70)
            
            Text(timeText(Int(remaining)))
                .font(.custom("NovaMono-Regular", size: 50))
                .foregroundStyle(tint)
                .offset(x: 25)
        }
    }
}
#Preview {
    TimerHUDView(remaining: 90, tint: .red, imageName: "Stage3tTimer")
}
