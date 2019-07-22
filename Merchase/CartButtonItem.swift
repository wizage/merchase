//
//  CartButtonItem.swift
//  Merchase
//
//  Created by Sam Patzer on 7/2/19.
//  Copyright © 2019 wizage. All rights reserved.
//

import UIKit

class CartButtonItem: UIBarButtonItem {

    private var handle: UInt8 = 0
    private var badgeVisible = false
    private var label: CATextLayer!
    private var badge: CAShapeLayer!
    private var radius: CGFloat!
    private var location: CGPoint!
    private var offset: CGPoint!
    
    private var badgeLayer: CAShapeLayer? {
        if let b: AnyObject = objc_getAssociatedObject(self, &handle) as AnyObject? {
            return b as? CAShapeLayer
        } else {
            return nil
        }
    }
    
    func addBadge(number: Int, withOffset offset: CGPoint = CGPoint(x: 4, y: 4), andColor color: UIColor = UIColor.red, andFilled filled: Bool = true) {
        guard let view = self.value(forKey:"view") as? UIView else { print("error");return }
        badgeLayer?.removeFromSuperlayer()
        
        // Initialize Badge
        badge = CAShapeLayer()
        radius = CGFloat(7)
        location = CGPoint(x: view.frame.width - (radius + offset.x), y: (radius + offset.y))
        
        self.offset = offset
        let length = "\(number)".count - 1
        let origin = CGPoint(x: location.x - radius, y: location.y - radius)
        badge.fillColor = filled ? color.cgColor : UIColor.white.cgColor
        badge.strokeColor = color.cgColor
        badge.path = UIBezierPath(roundedRect: CGRect(origin: origin, size: CGSize(width: (radius * 2) + CGFloat(length)*5.25, height: radius * 2)), cornerRadius: radius ).cgPath
        badge.lineWidth = 1.2
        view.layer.addSublayer(badge)
        
        // Initialiaze Badge's label
        label = CATextLayer()
        label.string = "\(number)"
        label.alignmentMode = .center
        label.fontSize = 11
        label.frame = CGRect(origin: CGPoint(x: location.x - 4, y: offset.y), size: CGSize(width: 8 + CGFloat(length*5), height: 16))
        label.foregroundColor = filled ? UIColor.white.cgColor : color.cgColor
        label.backgroundColor = UIColor.clear.cgColor
        label.contentsScale = UIScreen.main.scale
        badge.addSublayer(label)
        badgeVisible = true
        
        // Save Badge as UIBarButtonItem property
        objc_setAssociatedObject(self, &handle, badge, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func updateBadge(number: Int) {
        if(badgeVisible == true){
            label.string = "\(number)"
            let origin = CGPoint(x: location.x - radius, y: location.y - radius)
            let length = "\(number)".count - 1
            label.frame = CGRect(origin: CGPoint(x: location.x - 4, y: offset.y), size: CGSize(width: 8 + CGFloat(length*5), height: 16))
            badge.path = UIBezierPath(roundedRect: CGRect(origin: origin, size: CGSize(width: (radius * 2) + CGFloat(length)*5.25, height: radius * 2)), cornerRadius: radius ).cgPath
        } else {
            addBadge(number: number)
        }
    }
    
    func removeBadge() {
        badgeLayer?.removeFromSuperlayer()
    }
    
}
