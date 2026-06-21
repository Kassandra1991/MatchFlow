//
//  FlowLayout.swift
//  MatchFlow
//

import SwiftUI

struct FlowLayout: View {
    let items: [String]
    let content: (String) -> SkillTag
    
    var body: some View {
        TagFlowLayout(spacing: 6) {
            ForEach(items, id: \.self) { item in
                content(item)
            }
        }
    }
}

struct TagFlowLayout: Layout {
    var spacing: CGFloat = 6
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard let width = proposal.width, width > 0 else {
            let height = subviews.reduce(CGFloat.zero) { partial, subview in
                partial + subview.sizeThatFits(proposal).height
            }
            return CGSize(width: proposal.width ?? 0, height: height)
        }

        var height: CGFloat = 0
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        let boundedProposal = ProposedViewSize(width: width, height: proposal.height)
        
        for subview in subviews {
            let size = subview.sizeThatFits(boundedProposal)
            if rowWidth + size.width > width && rowWidth > 0 {
                height += rowHeight + spacing
                rowWidth = 0
                rowHeight = 0
            }
            rowWidth += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        height += rowHeight
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        let boundedProposal = ProposedViewSize(width: bounds.width, height: proposal.height)
        
        for subview in subviews {
            let size = subview.sizeThatFits(boundedProposal)
            if x + size.width > bounds.maxX && x > bounds.minX {
                y += rowHeight + spacing
                x = bounds.minX
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(width: size.width, height: size.height))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
