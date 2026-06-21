//
//  InsightsProgressBadge.swift
//  MatchFlow
//

import SwiftUI

enum InsightsProgressBadgeStyle {
    case explored
    case applied
    case interviews
    case rejected
    case offer

    var assetName: String? {
        switch self {
        case .rejected: "ProgressRejected"
        case .offer: "ProgressOffer"
        default: nil
        }
    }

    func makeShape() -> AnyShape {
        switch self {
        case .explored:
            AnyShape(ScallopedCircleShape(lobes: 12, amplitude: 0.08))
        case .applied:
            AnyShape(ScallopedCircleShape(lobes: 20, amplitude: 0.06))
        case .interviews:
            AnyShape(RoundedHeptagonShape(cornerRadius: 12))
        case .rejected, .offer:
            AnyShape(Circle())
        }
    }
}

struct AnyShape: Shape {
    private let pathBuilder: (CGRect) -> Path

    init<S: Shape>(_ shape: S) {
        pathBuilder = { rect in
            shape.path(in: rect)
        }
    }

    func path(in rect: CGRect) -> Path {
        pathBuilder(rect)
    }
}

struct InsightsProgressBadge: View {
    let count: Int
    let label: String
    let style: InsightsProgressBadgeStyle
    let action: () -> Void

    private let badgeSize: CGFloat = 96
    private let badgeWidth: CGFloat = 104

    var body: some View {
        Button(action: action) {
            ZStack {
                badgeBackground
                    .frame(width: badgeSize, height: badgeSize)

                VStack(spacing: DSSpacing.s2) {
                    Text("\(count)")
                        .textStyle(.header1)
                        .foregroundStyle(Color.foregroundPrimary)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)

                    Text(label)
                        .textStyle(.captionRegular)
                        .foregroundStyle(Color.foregroundSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, DSSpacing.s8)
            }
            .frame(width: badgeWidth, height: badgeSize)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var badgeBackground: some View {
        if let assetName = style.assetName {
            Color.backgroundSecondary
                .mask {
                    Image(assetName)
                        .resizable()
                        .scaledToFit()
                }
        } else {
            style.makeShape()
                .fill(Color.backgroundSecondary)
        }
    }
}

struct ScallopedCircleShape: Shape {
    let lobes: Int
    let amplitude: CGFloat

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let baseRadius = min(rect.width, rect.height) / 2 * (1 - amplitude)
        let bump = min(rect.width, rect.height) / 2 * amplitude

        var path = Path()
        let steps = lobes * 8

        for step in 0...steps {
            let angle = (Double(step) / Double(steps)) * 2 * .pi - .pi / 2
            let lobeAngle = angle * Double(lobes)
            let radius = baseRadius + bump * (0.5 + 0.5 * cos(lobeAngle))
            let point = CGPoint(
                x: center.x + CGFloat(cos(angle)) * radius,
                y: center.y + CGFloat(sin(angle)) * radius
            )
            if step == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

struct RoundedHeptagonShape: Shape {
    let cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        let sides = 7
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        var vertices: [CGPoint] = []
        for index in 0..<sides {
            let angle = (Double(index) / Double(sides)) * 2 * .pi - .pi / 2
            vertices.append(
                CGPoint(
                    x: center.x + CGFloat(cos(angle)) * radius,
                    y: center.y + CGFloat(sin(angle)) * radius
                )
            )
        }

        var path = Path()
        for index in 0..<sides {
            let current = vertices[index]
            let next = vertices[(index + 1) % sides]
            let previous = vertices[(index - 1 + sides) % sides]

            let toPrevious = CGPoint(x: current.x - previous.x, y: current.y - previous.y)
            let toNext = CGPoint(x: next.x - current.x, y: next.y - current.y)
            let previousLength = hypot(toPrevious.x, toPrevious.y)
            let nextLength = hypot(toNext.x, toNext.y)

            let insetPrevious = min(cornerRadius, previousLength / 2)
            let insetNext = min(cornerRadius, nextLength / 2)

            let start = CGPoint(
                x: current.x - toPrevious.x / previousLength * insetPrevious,
                y: current.y - toPrevious.y / previousLength * insetPrevious
            )
            let end = CGPoint(
                x: current.x + toNext.x / nextLength * insetNext,
                y: current.y + toNext.y / nextLength * insetNext
            )

            if index == 0 {
                path.move(to: start)
            } else {
                path.addLine(to: start)
            }
            path.addQuadCurve(to: end, control: current)
        }
        path.closeSubpath()
        return path
    }
}
