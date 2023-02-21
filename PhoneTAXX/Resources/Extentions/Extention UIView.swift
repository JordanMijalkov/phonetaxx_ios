//
//  extension UIView.swift
//  CornerShop
//
//  Created by SMIT 005 on 25/03/21.
//  Copyright © 2021 ShubhamSharma. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func addCommonShadowToAll(){
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 10
        self.layer.shadowRadius = 10
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = .zero
        self.layer.shadowOpacity = 0.4
    }
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    // MARK: visibility methods
    public enum Visibility : Int {
        case visible = 0
        case invisible = 1
        case gone = 2
        case goneY = 3
        case goneX = 4
    }

    public var visibility: Visibility {
        set {
            switch newValue {
                case .visible:
                    isHidden = false
                    getConstraintY(false)?.isActive = false
                    getConstraintX(false)?.isActive = false
                case .invisible:
                    isHidden = true
                    getConstraintY(false)?.isActive = false
                    getConstraintX(false)?.isActive = false
                case .gone:
                    isHidden = true
                    getConstraintY(true)?.isActive = true
                    getConstraintX(true)?.isActive = true
                case .goneY:
                    isHidden = true
                    getConstraintY(true)?.isActive = true
                    getConstraintX(false)?.isActive = false
                case .goneX:
                    isHidden = true
                    getConstraintY(false)?.isActive = false
                    getConstraintX(true)?.isActive = true
            }
        }
        get {
            if isHidden == false {
                return .visible
            }
            if getConstraintY(false)?.isActive == true && getConstraintX(false)?.isActive == true {
                return .gone
            }
            if getConstraintY(false)?.isActive == true {
                return .goneY
            }
            if getConstraintX(false)?.isActive == true {
                return .goneX
            }
            return .invisible
        }
    }

    fileprivate func getConstraintY(_ createIfNotExists: Bool = false) -> NSLayoutConstraint? {
        return getConstraint(.height, createIfNotExists)
    }

    fileprivate func getConstraintX(_ createIfNotExists: Bool = false) -> NSLayoutConstraint? {
        return getConstraint(.width, createIfNotExists)
    }

    fileprivate func getConstraint(_ attribute: NSLayoutConstraint.Attribute, _ createIfNotExists: Bool = false) -> NSLayoutConstraint? {
        var result: NSLayoutConstraint? = nil
        for constraint in constraints {
            if constraint.firstAttribute == attribute && constraint.constant == 0 && constraint.relation == .equal {
                result = constraint
                break
            }
        }
        if result == nil && createIfNotExists {
            // create and add the constraint
            result = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 0)
            addConstraint(result!)
        }
        return result
    }
    
    
    func fadeIn() {
        // Move our fade out code from earlier
        UIView.animate(withDuration: 1.0, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0 // Instead of a specific instance of, say, birdTypeLabel, we simply set [thisInstance] (ie, self)'s alpha
        }, completion: nil)
    }
    
    func fadeOut() {
        UIView.animate(withDuration: 1.0, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.alpha = 0.0
        }, completion: nil)
    }
    
    func addShadowAllCorner(top: Bool,
                   left: Bool,
                   bottom: Bool,
                   right: Bool,
                   shadowRadius: CGFloat = 4.0){
       // self.borderStyle = UITextField.BorderStyle.roundedRect
        self.layer.borderWidth = 0.0
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowRadius = 4.0
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowOpacity = 0.4
        
        let path = UIBezierPath()
        var x: CGFloat = 0
        var y: CGFloat = 0
        var viewWidth = self.frame.width
        var viewHeight = self.frame.height

        // here x, y, viewWidth, and viewHeight can be changed in
        // order to play around with the shadow paths.
        if (!top) {
            y+=(shadowRadius+1)
        }
        if (!bottom) {
            viewHeight-=(shadowRadius+1)
        }
        if (!left) {
            x+=(shadowRadius+1)
        }
        if (!right) {
            viewWidth-=(shadowRadius+1)
        }
        // selecting top most point
        path.move(to: CGPoint(x: x, y: y))
        // Move to the Bottom Left Corner, this will cover left edges
        /*
         |☐
         */
        path.addLine(to: CGPoint(x: x, y: viewHeight))
        // Move to the Bottom Right Corner, this will cover bottom edge
        /*
         ☐
         -
         */
        path.addLine(to: CGPoint(x: viewWidth, y: viewHeight))
        // Move to the Top Right Corner, this will cover right edge
        /*
         ☐|
         */
        path.addLine(to: CGPoint(x: viewWidth, y: y))
        // Move back to the initial point, this will cover the top edge
        /*
         _
         ☐
         */
        
        path.close()
        self.layer.shadowPath = path.cgPath
        
    }
    func addshadow(top: Bool,
                   left: Bool,
                   bottom: Bool,
                   right: Bool,
                   shadowRadius: CGFloat = 2.0) {

        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = 0.5
        self.layer.shadowColor = UIColor.lightGray.cgColor
        

        let path = UIBezierPath()
        var x: CGFloat = 0
        var y: CGFloat = 0
        var viewWidth = self.frame.width
        var viewHeight = self.frame.height

        // here x, y, viewWidth, and viewHeight can be changed in
        // order to play around with the shadow paths.
        if (!top) {
            y+=(shadowRadius+1)
        }
        if (!bottom) {
            viewHeight-=(shadowRadius+1)
        }
        if (!left) {
            x+=(shadowRadius+1)
        }
        if (!right) {
            viewWidth-=(shadowRadius+1)
        }
        // selecting top most point
        path.move(to: CGPoint(x: x, y: y))
        // Move to the Bottom Left Corner, this will cover left edges
        /*
         |☐
         */
        path.addLine(to: CGPoint(x: x, y: viewHeight))
        // Move to the Bottom Right Corner, this will cover bottom edge
        /*
         ☐
         -
         */
        path.addLine(to: CGPoint(x: viewWidth, y: viewHeight))
        // Move to the Top Right Corner, this will cover right edge
        /*
         ☐|
         */
        path.addLine(to: CGPoint(x: viewWidth, y: y))
        // Move back to the initial point, this will cover the top edge
        /*
         _
         ☐
         */
        
        path.close()
        self.layer.shadowPath = path.cgPath
    }
    func addDashBorder() {
           let color = UIColor.white.cgColor

           let shapeLayer:CAShapeLayer = CAShapeLayer()

           let frameSize = self.frame.size
           let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)

           shapeLayer.bounds = shapeRect
           shapeLayer.name = "DashBorder"
           shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
           shapeLayer.fillColor = UIColor.clear.cgColor
           shapeLayer.strokeColor = color
           shapeLayer.lineWidth = 1.5
           shapeLayer.lineJoin = .round
           shapeLayer.lineDashPattern = [2,4]
           shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 10).cgPath

           self.layer.masksToBounds = false

           self.layer.addSublayer(shapeLayer)
       }
    
    
}
