//
//  Created by Artem Novichkov on 07.06.2026.
//

import SwiftUI

struct AnimatedGradientBackground: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30)) { timeline in
            let phase = timeline.date.timeIntervalSinceReferenceDate / 7

            MeshGradient(
                width: 3,
                height: 3,
                points: points(for: phase),
                colors: [
                    .indigo.opacity(0.46), .black.opacity(0.92), .teal.opacity(0.24),
                    .black.opacity(0.88), .purple.opacity(0.42), .black.opacity(0.9),
                    .pink.opacity(0.24), .black.opacity(0.9), .blue.opacity(0.34)
                ]
            )
        }
        .ignoresSafeArea()
    }

    private func points(for phase: TimeInterval) -> [SIMD2<Float>] {
        [
            [0, 0],
            [Float(0.48 + 0.14 * sin(phase)), 0],
            [1, 0],
            [0, Float(0.48 + 0.13 * cos(phase * 0.74))],
            [
                Float(0.5 + 0.20 * sin(phase * 0.82 + 1.1)),
                Float(0.5 + 0.18 * cos(phase * 0.68 + 0.7))
            ],
            [1, Float(0.5 + 0.14 * sin(phase * 0.91 + 2.4))],
            [0, 1],
            [Float(0.52 + 0.14 * cos(phase * 0.78 + 1.8)), 1],
            [1, 1]
        ]
    }
}
