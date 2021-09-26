//
//  UIKit+Extensions.swift
//  rithnnn (iOS)
//
//  Created by Michael Forrest on 26/09/2021.
//

import UIKit

extension CGRect{
    var center: CGPoint{
        CGPoint(x: width / 2, y: height / 2)
    }
    var radius: CGFloat{
        width / 2
    }
}
