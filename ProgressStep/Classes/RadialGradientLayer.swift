//
//  RadialGradientLayer.swift
//  ProgressStep
//
//  Created by Sergey Lukoyanov on 17.07.17.
//  Copyright © 2017 Sergey Lukoyanov. All rights reserved.
//

import UIKit

class RadialGradientLayer: CALayer {
    
    var center:CGPoint = CGPoint(x: 50, y: 50)
    var minRadius: CGFloat = 0
    var maxRadius: CGFloat = 100
    var colors:[CGColor] = [UIColor.red.cgColor , UIColor.yellow.cgColor]

    
    override init(){
        super.init()
        
        needsDisplayOnBoundsChange = true
    }
    
    init(center:CGPoint,minRadius:CGFloat, maxRadius:CGFloat, colors:[CGColor]) {
        self.center = center
        self.minRadius = minRadius
        self.maxRadius = maxRadius
        self.colors = colors
        
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        
        super.init()
        
    }
    
    override func draw(in ctx: CGContext) {
        ctx.saveGState()

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0.0,1.0])
        ctx.drawRadialGradient(gradient!, startCenter: center, startRadius: minRadius, endCenter: center, endRadius: maxRadius, options: CGGradientDrawingOptions(rawValue: 0))
    }
    
}
