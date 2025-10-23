//
//  SkeletonModifier.swift
//  Skeleton
//
//  Created by Balaji Venkatesh on 13/04/25.
//

import SwiftUI

extension View {
    func skeleton(isRedacted: Bool) -> some View {
        self
            .modifier(SkeletonModifier(isRedacted: isRedacted))
    }
}

struct SkeletonModifier: ViewModifier {
    var isRedacted: Bool
    /// View Properties
    @State private var isAnimating: Bool = false
    @Environment(\.colorScheme) private var scheme
    func body(content: Content) -> some View {
        content
            .redacted(reason: isRedacted ? .placeholder : [])
            /// Skeleton Effect
            .overlay {
                if isRedacted {
                    GeometryReader {
                        let size = $0.size
                        let skeletonWidth = size.width / 2
                        /// Limiting blur radius to 30+
                        let blurRadius = max(skeletonWidth / 3, 30)
                        let blurDiameter = blurRadius * 2
                        /// Movement Offsets
                        let minX = -(skeletonWidth + blurDiameter)
                        let maxX = size.width + skeletonWidth + blurDiameter
                        
                        Rectangle()
                            .fill(scheme == .dark ? .white : .black)
                            .frame(width: skeletonWidth, height: size.height * 2)
                            .frame(height: size.height)
                            .blur(radius: blurRadius)
                            .rotationEffect(.init(degrees: rotation))
                            /// Moving from left-right in-definetely
                            .offset(x: isAnimating ? maxX : minX)
                    }
                    .mask {
                        content
                            .redacted(reason: .placeholder)
                    }
                    .blendMode(.softLight)
                    .task { @MainActor in
                        guard !isAnimating else { return }
                        withAnimation(animation) {
                            isAnimating = true
                        }
                    }
                    .onDisappear {
                        /// Stopping Animation
                        isAnimating = false
                    }
                    .transaction {
                        if $0.animation != animation {
                            $0.animation = .none
                        }
                    }
                }
            }
    }

    /// Customizable Properties
    var rotation: Double {
        return 5
    }

    var animation: Animation {
        .easeInOut(duration: 1.5).repeatForever(autoreverses: false)
    }
}


#Preview {
  //  TaskSectionView(tasks: TaskModel.mocks, isLoading: true) { task in
   //     TaskCardView()
  //  }
}

