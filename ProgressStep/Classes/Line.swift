//
//  Line.swift
//  ProgressView
//
//  Created by Admin on 18.07.17.
//  Copyright © 2017 Sergey Lukoyanov. All rights reserved.
//

import Foundation
import UIKit

enum LineType {
    case incomplete
    case complete
}

struct Line {
    var type: LineType
    let start: CGPoint
    let end: CGPoint
}
