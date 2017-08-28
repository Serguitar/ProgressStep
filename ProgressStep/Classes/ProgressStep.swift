//
//  ProgressStep.swift
//  ProgressStep
//
//  Created by Sergey Lukoyanov on 17.07.17.
//  Copyright © 2017 Sergey Lukoyanov. All rights reserved.
//

import UIKit

@IBDesignable
class ProgressStep: UIView {
    
    private let linesZValue:UInt32     = 0
    private let gradientZValue:UInt32  = 1
    private let circlesZValue:UInt32   = 2
    
    @IBInspectable var count: Int = 4
    @IBInspectable var value: CGFloat = 1.5 {
        didSet {
            redraw()
        }
    }
    @IBInspectable var lineLength:CGFloat = 18.0
    @IBInspectable var radius: CGFloat = 12.0
    @IBInspectable var thickness: CGFloat = 1.0
    @IBInspectable var gradientWidth: CGFloat = 5.0
    @IBInspectable var selectedColor: UIColor = UIColor.red
    @IBInspectable var unselectedColor: UIColor = UIColor.gray
    @IBInspectable var gradientStartColor: UIColor = UIColor(colorLiteralRed: 1, green: 0, blue: 0, alpha: 0.3)
    @IBInspectable var gradientEndColor: UIColor = UIColor(colorLiteralRed: 1, green: 0, blue: 0, alpha: 0.01)

    var circlesArr = [Circle]()
    var linesArr = [Line]()
    var radGradientLayer: RadialGradientLayer!
    
    var layers = [CALayer]()
    
    
    override var intrinsicContentSize: CGSize {
        let width = 2*radius*CGFloat(count) + lineLength*(CGFloat(count) - 1) + gradientWidth*2
        let height = 2*(radius + gradientWidth)
        
        return CGSize(width: width, height: height)
    }


    override func draw(_ rect: CGRect) {
        if circlesArr.first == nil {
            prepare()
        }
        select(value: value)
        drawProgress()
    }
    
    
    func redraw() {
        for layer in layers {
            layer.removeFromSuperlayer()
        }
        layers.removeAll()
        circlesArr.removeAll()
        linesArr.removeAll()

        setNeedsDisplay()
    }
    
    
    internal func prepare() {
        let halfHeight = self.frame.size.height/2
        let y = halfHeight
        
        //cirles
        for i in 0 ..< count {
            let deltaX = (2*(radius) + lineLength) * CGFloat(i)
            let centerPoint = CGPoint(x: radius + deltaX +  gradientWidth, y: y)
            let circle = Circle(type: .empty, center: centerPoint, radius: radius)
            circlesArr.append(circle)
        }
        
        //lines
        if let firstCircle = circlesArr.first {
            var startPoint = CGPoint(x: firstCircle.center.x
                , y: firstCircle.center.y)
            for i in 1 ..< count {
                startPoint.x += radius
                let endPoint = CGPoint(x: startPoint.x + lineLength, y: startPoint.y)
                let line = Line(type: .incomplete, start: startPoint, end: endPoint)
                linesArr.append(line)
                startPoint = circlesArr[i].center
            }
        }
    }
    
    internal func select(value: CGFloat) {
        var validValue = value
        if validValue < 0 {
            validValue = 0
        } else if validValue > CGFloat(count) {
            validValue = CGFloat(count)
        }
        
        let valueInt = Int(validValue)
        let diff = validValue - CGFloat(valueInt)
        var needHalf = false
        let tollerance = 0.05
        if Double(abs(diff)) > Double(tollerance) {
            needHalf = true
        }
        let k = needHalf ? 0 : 1
        
        for i in  0 ..< valueInt {
            var circle = circlesArr[i]
            circle.type = .full
            circlesArr[i] = circle
        }
        
        if needHalf {
            var circle = circlesArr[valueInt]
            circle.type = .half
            circlesArr[valueInt] = circle
            
            let delta: CGFloat = 0.5 // inner radius of radial gradient is not antialiased, hide it under border line by decreasing min radius with delta
            drawGradient(center: circle.center, minRadius: circle.radius - delta, maxRadius: circle.radius + thickness/4 + gradientWidth, fromColor: gradientStartColor, toColor: gradientEndColor)
        }
        
        
        if valueInt > 0 {
            for i in  0 ..< valueInt - k {
                var line = linesArr[i]
                line.type = .complete
                linesArr[i] = line
            }
        }
    }
    
    internal func drawProgress() {
        for circle in circlesArr {
            let path = getCirclePath(circle: circle, thickness: thickness)
            if circle.type == .empty {
                draw(path: path, withColor: unselectedColor, fillColor: nil, zValue: circlesZValue)
            } else if circle.type == .half {
                draw(path: path, withColor: selectedColor, fillColor: nil, zValue: circlesZValue)
            } else {
                draw(path: path, withColor: selectedColor, fillColor: selectedColor, zValue: circlesZValue)
            }
        }
        
        for line in linesArr {
            let path = getLinePath(line: line, thickness: thickness)
            if line.type == .incomplete {
                 draw(path: path, withColor: unselectedColor, fillColor: nil, zValue: linesZValue)
            } else {
                draw(path: path, withColor: selectedColor, fillColor: nil, zValue: linesZValue)
            }
        }
    }
    
    internal func getCirclePath(circle: Circle, thickness: CGFloat) -> UIBezierPath {
        let circlePath = UIBezierPath(
            arcCenter: circle.center,
            radius: CGFloat(circle.radius - thickness/2),
            startAngle: CGFloat(0),
            endAngle:CGFloat(Double.pi * 2),
            clockwise: true)
        return circlePath
    }
    
    internal func getLinePath(line: Line, thickness: CGFloat) -> UIBezierPath {
        let linePath = UIBezierPath()

        var start = line.start
        start.x -= thickness/4
        var end = line.end
        end.x += thickness/4
        
        linePath.move(to: start)
        linePath.addLine(to: end)
        return linePath
    }

    
    internal func draw(path: UIBezierPath, withColor color: UIColor, fillColor: UIColor?, zValue: UInt32) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        if fillColor != nil {
            shapeLayer.fillColor = fillColor!.cgColor
        } else {
            shapeLayer.fillColor = UIColor.clear.cgColor
        }
        
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = thickness
        layer.insertSublayer(shapeLayer, at: zValue)
        layers.append(shapeLayer)
    }
    
    internal func drawGradient(center: CGPoint, minRadius: CGFloat, maxRadius:CGFloat, fromColor: UIColor, toColor: UIColor) {
        let color1 = fromColor
        let color2 = toColor
        
        radGradientLayer = RadialGradientLayer.init(center: center, minRadius: minRadius, maxRadius: maxRadius, colors:  [color1.cgColor, color2.cgColor])
        
        radGradientLayer.frame = self.bounds
        radGradientLayer.setNeedsDisplay()
        layer.insertSublayer(radGradientLayer, at: gradientZValue)
        layers.append(radGradientLayer)
    }

}

