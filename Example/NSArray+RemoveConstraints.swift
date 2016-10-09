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
            if NSLayoutConstraint.responds(to: #selector(NSLayoutConstraint.deactivate(_:))) {
                NSLayoutConstraint.deactivate(self as! [NSLayoutConstraint])
                return
            }
        }
        
        for object in self {
            if (object as AnyObject).isKind(of: NSLayoutConstraint.self) {
                (object as! NSLayoutConstraint).gy_autoRemove()
            }
        }
    }
}
