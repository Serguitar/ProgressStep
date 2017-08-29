//
//  Figures.swift
//  ProgressView
//
//  Created by Sergey Lukoyanov on 18.07.17.
//  Copyright © 2017 Sergey Lukoyanov. All rights reserved.
//

import Foundation
import UIKit

enum FigureFillState {
    case empty
    case half
    case full
}

struct Circle {
    var state:  FigureFillState
    let center: CGPoint
    let radius: CGFloat
}

struct Rectangle {
    var state:  FigureFillState
    let frame:  CGRect
    let cornerRaius: CGFloat
}
