//
//  ProgressCircle.swift
//  rithnnn (iOS)
//
//  Created by Michael Forrest on 26/09/2021.
//

import SwiftUI

struct ProgressCircle: Shape{
    var progress: Double
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.addArc(
            center: rect.center,
            radius: rect.radius,
            startAngle: Angle(degrees: -90),
            endAngle: Angle(degrees: (360 * progress) - 90),
            clockwise: false
        )
        return p.strokedPath(.init(lineWidth: 3, lineCap: .round, dash: progress < 0 ? [3, 5] : [1], dashPhase: 0))
    }
}

struct ProgressCircle_Previews: PreviewProvider {
    static var previews: some View {
        ProgressCircle(progress: 0.5)
    }
}
