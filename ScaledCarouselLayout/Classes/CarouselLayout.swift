//
//  TMP.swift
//  ScaledCarousel
//
//  Created by Vadim Zhydenko on 1/27/18.
//  Copyright © 2018 Vadim Zhydenko. All rights reserved.
//

import UIKit

enum CarouselDirection {
    
    case any
    case left
    case right
    case top
    case bottom
    
}

class CarouselLayout: UICollectionViewLayout {
    
    @IBInspectable fileprivate var horizontal: Bool = false
    
    @IBInspectable fileprivate var aspectNormalHeight: CGFloat = 0.75
    @IBInspectable fileprivate var aspectCenterHeight: CGFloat = 0.85
    @IBInspectable fileprivate var aspectNormalWidth: CGFloat = 0.75
    @IBInspectable fileprivate var aspectCenterWidth: CGFloat = 0.85
    
    fileprivate var centerHeight: CGFloat = 0
    fileprivate var centerWidth: CGFloat = 0
    fileprivate var normalHeight: CGFloat = 0
    fileprivate var normalWidth: CGFloat = 0
    fileprivate var deltaX: CGFloat = 0
    fileprivate var deltaY: CGFloat = 0
    fileprivate var isIgnoringBoundsChange = false
    
    private var layoutInformation = [UICollectionViewLayoutAttributes]()
    private var currentVisibleRect: CGRect = .zero
    
    override var collectionViewContentSize: CGSize {
        let numberOfItems = collectionView!.numberOfItems(inSection: 0)
        if horizontal {
            let sideSpace = (collectionView!.bounds.width - centerWidth) / 2
            let width = normalWidth * CGFloat(numberOfItems - 1) + centerWidth + sideSpace * 2
            return CGSize(width: width, height: normalHeight)
        } else {
            let sideSpace = (collectionView!.bounds.height - centerHeight) / 2
            let height = normalHeight * CGFloat(numberOfItems - 1) + centerHeight + sideSpace * 2
            return CGSize(width: normalWidth, height: height)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        centerHeight = collectionView!.frame.height * aspectCenterHeight
        normalHeight = collectionView!.frame.height * aspectNormalHeight
        centerWidth = collectionView!.frame.width * aspectCenterWidth
        normalWidth = collectionView!.frame.width * aspectNormalWidth
        deltaX = centerWidth - normalWidth
        deltaY = centerHeight - normalHeight
    }
    
    override func prepare() {
        let numberOfItems = collectionView!.numberOfItems(inSection: 0)
        if layoutInformation.count != numberOfItems {
            layoutInformation = (0..<numberOfItems).map {
                UICollectionViewLayoutAttributes(forCellWith: IndexPath(row: $0, section: 0))
            }
            updateLayout(for: collectionView!.bounds)
        } else {
            updateLayout(for: currentVisibleRect)
        }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutInformation[indexPath.item]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return layoutInformation.filter { $0.frame.intersects(rect) }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        currentVisibleRect = newBounds
        return !isIgnoringBoundsChange
    }
    
    func updateLayout(for newBounds: CGRect) {
        if horizontal {
            updateHorizontalLayout(for: newBounds)
        } else {
            updateVerticalLayout(for: newBounds)
        }
    }
    
    func updateHorizontalLayout(for newBounds: CGRect) {
        let leftInset = (newBounds.width - centerWidth) / 2
        let normalOffsetY = (newBounds.height - normalHeight) / 2
        for attribute in layoutInformation {
            let normalOffsetX = leftInset + CGFloat(attribute.indexPath.row) * normalWidth
            let distanceCenters = normalOffsetX - newBounds.midX + centerWidth / 2
            let normalizedCenter = distanceCenters / normalWidth
            update(attribute, normalizedCenter, normalOffsetX, normalOffsetY)
        }
    }
    
    func updateVerticalLayout(for newBounds: CGRect) {
        let topInset = (newBounds.height - centerHeight) / 2
        let normalOffsetX = (newBounds.width - normalWidth) / 2
        for attribute in layoutInformation {
            let normalOffsetY = topInset + CGFloat(attribute.indexPath.row) * normalHeight
            let distanceCenters = normalOffsetY - newBounds.midY + centerHeight / 2
            let normalizedCenter = distanceCenters / normalHeight
            update(attribute, normalizedCenter, normalOffsetX, normalOffsetY)
        }
    }
    
    func update(_ attr: UICollectionViewLayoutAttributes, _ center: CGFloat, _ normalX: CGFloat, _ normalY: CGFloat) {
        let isCenter = fabs(center) < 1
        if isCenter {
            let koef = 1 - fabs(center)
            let incrementX = koef * deltaX
            let incrementY = koef * deltaY
            let offsetX = horizontal ? (center > 0 ? deltaX - incrementX : 0) : -incrementX / 2
            let offsetY = horizontal ? -incrementY / 2 : (center > 0 ? deltaY - incrementY : 0)
            attr.frame = CGRect(x: normalX + offsetX, y: normalY + offsetY,
                                width: normalWidth + incrementX,
                                height: normalHeight + incrementY)
        } else {
            let isBottomRight = (center > 0) && !isCenter
            attr.frame = CGRect(x: normalX + ((horizontal && isBottomRight) ? deltaX : 0),
                                y: normalY + ((!horizontal && isBottomRight) ? deltaY : 0),
                                width: normalWidth, height: normalHeight)
        }
    }
    
    
}

extension CarouselLayout {
    
    func nearestIndex(_ point: CGPoint, _ direction: CarouselDirection, _ horizontal: Bool) -> Int {
        switch direction {
        case .any:
            let coord = horizontal ? point.x : point.y
            let topLeftDirection: CarouselDirection = horizontal ? .left : .top
            let bottomRightDirection: CarouselDirection = horizontal ? .right : .bottom
            let topLeftIndex = index(for: coord, direction: topLeftDirection)
            let topLeftCenter = distance(topLeftIndex, coord, direction: topLeftDirection)
            let bottomRightIndex = index(for: coord, direction: bottomRightDirection)
            let bottomRightCenter = distance(bottomRightIndex, coord, direction: bottomRightDirection)
            return topLeftCenter > bottomRightCenter ? bottomRightIndex : topLeftIndex
        case .left, .right: return index(for: point.x, direction: direction)
        case .top, .bottom: return index(for: point.y, direction: direction)
        }
    }
    
    func offset(for index: Int, _ horizontal: Bool) -> CGPoint {
        return CGPoint(x: CGFloat(index) * (horizontal ? self.normalWidth : 0),
                       y: CGFloat(index) * (horizontal ? 0 : self.normalHeight))
    }
    
    func index(for center: CGFloat, direction: CarouselDirection) -> Int {
        let size = collectionView!.bounds.size
        switch direction {
        case .top:
            return Int((center - centerHeight + normalHeight) / normalHeight)
        case .left:
            return Int((center - centerWidth + normalWidth) / normalWidth)
        case .bottom:
            return Int(((center - size.height / 2 - centerHeight + normalHeight) / normalHeight).rounded(.up))
        case .right:
            return Int(((center - size.width / 2 - centerWidth + normalWidth) / normalWidth).rounded(.up))
        default: return 0
        }
    }
    
    func distance(_ index: Int, _ center: CGFloat, direction: CarouselDirection) -> CGFloat {
        let size = collectionView!.bounds.size
        switch direction {
        case .top:
            return center - CGFloat(index) * normalHeight - size.height / 2 - centerHeight + normalHeight
        case .left:
            return center - CGFloat(index) * normalWidth - size.width / 2 - centerWidth + normalWidth
        case .bottom:
            return CGFloat(index) * normalWidth + size.height / 2 - center - centerHeight + normalHeight
        case .right:
            return CGFloat(index) * normalWidth + size.width / 2 - center - centerWidth + normalWidth
        default: return 0
        }
    }
    
}

class CarouselLayoutVC: UIViewController, UICollectionViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let cell = scrollView.subviews.first(where: { $0.isKind(of: UICollectionViewCell.self) }) as? UICollectionViewCell,
            let collectionView = cell.superview as? UICollectionView,
            let layout = collectionView.collectionViewLayout as? CarouselLayout else { return }
        let scrollVelocity = layout.horizontal ? velocity.x : velocity.y
        let topLeft: CarouselDirection = layout.horizontal ? .left : .top
        let bottomRight: CarouselDirection = layout.horizontal ? .right : .bottom
        let dir: CarouselDirection = (scrollVelocity == 0) ? .any : ((scrollVelocity < 0) ? topLeft : bottomRight)
        let nearsetIndex = layout.nearestIndex(targetContentOffset.pointee, dir, layout.horizontal)
        targetContentOffset.pointee = layout.offset(for: nearsetIndex, layout.horizontal)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let layout = collectionView.collectionViewLayout as? CarouselLayout else { return }
        let position = CGFloat(indexPath.row) * (layout.horizontal ? layout.normalWidth : layout.normalHeight)
        layout.isIgnoringBoundsChange = true
        collectionView.setContentOffset(CGPoint(x: layout.horizontal ? position : 0,
                                                y: layout.horizontal ? 0 : position),
                                        animated: true)
        layout.isIgnoringBoundsChange = false
    }
    
}

