//
//  Circle.swift
//  ProgressView
//
//  Created by Sergey Lukoyanov on 18.07.17.
//  Copyright © 2017 Sergey Lukoyanov. All rights reserved.
//

import Foundation
import UIKit

enum CircleType {
    case empty
    case half
    case full
}

struct Circle {
    var type: CircleType
    let center: CGPoint
    let radius: CGFloat
}

