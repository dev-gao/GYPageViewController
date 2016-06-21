//
//  UIView+RemoveConstraints.swift
//  PreciousMetals
//
//  Created by GaoYu on 16/5/29.
//  Copyright © 2016年 Dev-GY. All rights reserved.
//

import UIKit

extension UIView {
    func gy_removeConstraintsAffectingView() {
        var currentSuperView = self.superview
        let constraintsToRemove = NSMutableArray()
        while currentSuperView != nil {
            if let constraints = currentSuperView?.constraints {
                for c in constraints {
                    let isImplicitConstraint = (NSStringFromClass(c.dynamicType) == "NSContentSizeLayoutConstraint")
                    if isImplicitConstraint != true {
                        if self.isEqual(c.firstItem) || self.isEqual(c.secondItem) {
                            constraintsToRemove.addObject(c)
                        }
                    }
                }
            }
            currentSuperView = currentSuperView?.superview
        }
        
        constraintsToRemove.gy_autoRemoveConstraints()
    }
    
    func gy_commonSuperviewWithView(otherView:UIView) -> UIView? {
        var startView:UIView? = self
        var commonSuperview:UIView?
        
        repeat {
            if let obj = startView {
                if otherView.isDescendantOfView(obj) {
                    commonSuperview = obj
                }
            }
            startView = startView?.superview
        } while (startView != nil && commonSuperview == nil)
        assert(commonSuperview != nil, "Can't constrain two views that do not share a common superview. Make sure that both views have been added into the same view hierarchy.")
        return commonSuperview;
    }
}
