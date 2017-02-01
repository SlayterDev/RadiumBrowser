//
//  UIViewExtensions.swift
//  RadiumBrowser
//
//  Created by bslayter on 1/31/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit

extension UIView {
    
    public enum Corner: Int {
        case TopRight
        case TopLeft
        case BottomRight
        case BottomLeft
        case All
    }
    
    public func blendCorner(corner: Corner, shapeLayer: inout CAShapeLayer?, length: CGFloat = 8.0) {
        let maskLayer = CAShapeLayer()
        let path: CGPath
        let outlinePath: UIBezierPath
        switch corner {
        case .All:
            (path, outlinePath) = self.makeAnglePathWithRect(self.bounds, topLeftSize: length, topRightSize: length, bottomLeftSize: 0.0, bottomRightSize: 0.0)
        case .TopRight:
            (path, outlinePath) = self.makeAnglePathWithRect(self.bounds, topLeftSize: 0.0, topRightSize: length, bottomLeftSize: 0.0, bottomRightSize: 0.0)
        case .TopLeft:
            (path, outlinePath) = self.makeAnglePathWithRect(self.bounds, topLeftSize: length, topRightSize: 0.0, bottomLeftSize: 0.0, bottomRightSize: 0.0)
        case .BottomRight:
            (path, outlinePath) = self.makeAnglePathWithRect(self.bounds, topLeftSize: 0.0, topRightSize: 0.0, bottomLeftSize: 0.0, bottomRightSize: length)
        case .BottomLeft:
            (path, outlinePath) = self.makeAnglePathWithRect(self.bounds, topLeftSize: 0.0, topRightSize: 0.0, bottomLeftSize: length, bottomRightSize: 0.0)
        }
        maskLayer.path = path
        self.layer.mask = maskLayer
        
        if shapeLayer == nil {
            shapeLayer = CAShapeLayer()
        }
        shapeLayer?.frame = self.bounds
        shapeLayer?.path = outlinePath.cgPath
        shapeLayer?.lineWidth = 1.0
        shapeLayer?.strokeColor = UIColor.gray.cgColor
        shapeLayer?.fillColor = UIColor.clear.cgColor
        if shapeLayer?.superlayer == nil {
            self.layer.addSublayer(shapeLayer!)
        }
    }
    
    private func makeAnglePathWithRect(_ rect: CGRect, topLeftSize tl: CGFloat, topRightSize tr: CGFloat, bottomLeftSize bl: CGFloat, bottomRightSize br: CGFloat) -> (CGPath, UIBezierPath) {
        var points = [CGPoint]()
        
        points.append(CGPoint(x: rect.origin.x + tl, y: rect.origin.y))
        points.append(CGPoint(x: rect.origin.x + rect.size.width - tr, y: rect.origin.y))
        points.append(CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height))
        points.append(CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height - br))
        points.append(CGPoint(x: rect.origin.x + rect.size.width - br, y: rect.origin.y + rect.size.height))
        points.append(CGPoint(x: rect.origin.x + bl, y: rect.origin.y + rect.size.height))
        points.append(CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height - bl))
        points.append(CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height))
        
        let outlinePoints = points[0..<points.count - 3]
        
        let path = CGMutablePath()
        path.move(to: points.first!)
        for point in points {
            if point != points.first {
                path.addLine(to: point)
            }
        }
        path.addLine(to: points.first!)
        
        let outlinePath = UIBezierPath()
        outlinePath.move(to: outlinePoints.first!)
        for point in outlinePoints {
            if point != outlinePoints.first {
                outlinePath.addLine(to: point)
            }
        }
//        outlinePath.addLine(to: outlinePoints.first!)
        
        return (path, outlinePath)
    }
    
}
