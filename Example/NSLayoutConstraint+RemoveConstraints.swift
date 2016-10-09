//
//  NSLayoutConstraint+RemoveConstraints.swift
//  PreciousMetals
//
//  Created by GaoYu on 16/5/29.
//  Copyright © 2016年 Dev-GY. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    func gy_autoRemove() {
        if #available(iOS 8.0, *) {
            self.isActive = false
            return
        }
        
        if self.secondItem != nil {
            var commonSuperview:UIView?
            commonSuperview = (self.firstItem as! UIView).gy_commonSuperviewWithView(self.secondItem as! UIView)
            while commonSuperview != nil {
                if commonSuperview?.constraints.contains(self) == true {
                    commonSuperview?.removeConstraint(self)
                    return
                }
                commonSuperview = commonSuperview?.superview
            }
        }
        else {
            self.firstItem.removeConstraint(self)
            return
        }
        assert(false, "Failed to remove constraint: \(self)")
    }
}
