//
//  NSArray+RemoveConstraints.swift
//  PreciousMetals
//
//  Created by GaoYu on 16/5/29.
//  Copyright © 2016年 Dev-GY. All rights reserved.
//

import UIKit

extension NSArray {

    func gy_autoRemoveConstraints() {
        if #available(iOS 8.0, *) {
            if NSLayoutConstraint.respondsToSelector(#selector(NSLayoutConstraint.deactivateConstraints)) {
                NSLayoutConstraint.deactivateConstraints(self as! [NSLayoutConstraint])
                return
            }
        }
        
        for object in self {
            if object.isKindOfClass(NSLayoutConstraint.self) {
                (object as! NSLayoutConstraint).gy_autoRemove()
            }
        }
    }
}
