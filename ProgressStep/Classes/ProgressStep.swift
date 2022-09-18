//
//  ProgressStep.swift
//  ProgressStep
//
//  Created by Sergey Lukoyanov on 17.07.17.
//  Copyright © 2017 Sergey Lukoyanov. All rights reserved.
//

import UIKit

@IBDesignable
public class ProgressStep: UIView {
    
    private let linesZValue:UInt32     = 0
    private let gradientZValue:UInt32  = 1
    private let shapesZValue:UInt32   = 2
    
    @IBInspectable public var count: Int = 4
    @IBInspectable public var value: CGFloat = 1.5 {
        didSet {
            redraw()
        }
    }
    @IBInspectable public var isCircle:Bool = true
    @IBInspectable public var allowHalf:Bool = true
    @IBInspectable var radius: CGFloat = 12.0  //radius for circle and half width for rectanle
    @IBInspectable var thickness: CGFloat = 1.0
    @IBInspectable var lineLength:CGFloat = 18.0
    @IBInspectable var lineThickness:CGFloat = -1 //negative value means that line thickness will be same as thickness. 0 - remove line
    @IBInspectable var cornerRadius: CGFloat = 3.0 //only for rectangles
    @IBInspectable var gradientWidth: CGFloat = 5.0
    @IBInspectable var selectedColor: UIColor = UIColor.red
    @IBInspectable var unselectedColor: UIColor = UIColor.gray
    @IBInspectable var unselectedFillColor: UIColor = UIColor.white
    
    //gradient (only for circles)
    @IBInspectable var gradientStartColor: UIColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.3)
    @IBInspectable var gradientEndColor: UIColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.01)

    private var circlesArr = [Circle]()
    private var rectanglesArr = [Rectangle]()
    private var linesArr = [Line]()
    private var radGradientLayer: RadialGradientLayer!
    private var layers = [CALayer]()
    
    public override var intrinsicContentSize: CGSize {
        if isCircle == true {
            let width = 2*radius*CGFloat(count) + lineLength*(CGFloat(count) - 1) + gradientWidth*2
            let height = 2*(radius + gradientWidth)
            return CGSize(width: width, height: height)
        } else {
            let width = 2*radius*CGFloat(count) + lineLength*(CGFloat(count) - 1)
            return CGSize(width: width, height: self.frame.size.height)
        }
    }

    public override func draw(_ rect: CGRect) {
        if circlesArr.first == nil {
            prepare()
        }
        select(value: value)
        drawProgress()
    }
    
    private func redraw() {
        for layer in layers {
            layer.removeFromSuperlayer()
        }
        layers.removeAll()
        circlesArr.removeAll()
        rectanglesArr.removeAll()
        linesArr.removeAll()

        setNeedsDisplay()
    }
    
    private func prepare() {
        let halfHeight = self.frame.size.height/2
        let y = halfHeight
        
        if isCircle == true {
            //cirles
            for i in 0 ..< count {
                let deltaX = (2*(radius) + lineLength) * CGFloat(i)
                let centerPoint = CGPoint(x: radius + deltaX +  gradientWidth, y: y)
                let circle = Circle(state: .empty, center: centerPoint, radius: radius)
                circlesArr.append(circle)
            }
        } else {
            //rectangles
            for i in 0 ..< count {
                let deltaX = (2*(radius) + lineLength) * CGFloat(i)
                let origin = CGPoint(x: deltaX, y: 0)
                let frame = CGRect(origin: origin, size: CGSize(width: 2 * radius, height: 2 * halfHeight))
                let rectangle = Rectangle(state: .empty, frame: frame, cornerRaius: cornerRadius)
                rectanglesArr.append(rectangle)
            }
        }
        
        //lines
        var startPoint: CGPoint?
        if let firstCircle = circlesArr.first {
            startPoint = CGPoint(x: firstCircle.center.x
                , y: firstCircle.center.y)
        } else if let firstRectangle = rectanglesArr.first {
            startPoint = CGPoint(x: firstRectangle.frame.midX, y: firstRectangle.frame.midY)
        }
        
        guard var aStartPoint = startPoint else {
            return
        }
        
        for i in 1 ..< count {
            aStartPoint.x += radius
            let endPoint = CGPoint(x: aStartPoint.x + lineLength, y: aStartPoint.y)
            let line = Line(type: .incomplete, start: aStartPoint, end: endPoint)
            linesArr.append(line)
            if isCircle == true {
                aStartPoint = circlesArr[i].center
            } else {
                let rectangle = rectanglesArr[i]
                aStartPoint = CGPoint(x: rectangle.frame.midX, y: rectangle.frame.midY)
            }
        }
    }
    
    private func select(value: CGFloat) {
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
        if allowHalf == false {
            needHalf = false
        }
        
        let k = needHalf ? 0 : 1
        
        for i in  0 ..< valueInt {
            if isCircle == true {
                var circle = circlesArr[i]
                circle.state = .full
                circlesArr[i] = circle
            } else {
                var rectangle = rectanglesArr[i]
                rectangle.state = .full
                rectanglesArr[i] = rectangle
            }
        }
        
        if needHalf && allowHalf == true {
            if isCircle == true {
                var circle = circlesArr[valueInt]
                circle.state = .half
                circlesArr[valueInt] = circle
                
                let delta: CGFloat = 0.5 // inner radius of radial gradient is not antialiased, hide it under border line by decreasing min radius with delta
                drawGradient(center: circle.center, minRadius: circle.radius - delta, maxRadius: circle.radius + thickness/4 + gradientWidth, fromColor: gradientStartColor, toColor: gradientEndColor)
            } else {
                var rectangle = rectanglesArr[valueInt]
                rectangle.state = .half
                rectanglesArr[valueInt] = rectangle
            }
        }
        
        if valueInt > 0  {
            for i in  0 ..< valueInt - k {
                var line = linesArr[i]
                line.type = .complete
                linesArr[i] = line
            }
        }
    }
    
    private func drawProgress() {
        if isCircle == true {
            for circle in circlesArr {
                let path = getCirclePath(circle: circle, thickness: thickness)
                if circle.state == .empty {
                    draw(path: path, withColor: unselectedColor, fillColor: unselectedFillColor, zValue: shapesZValue)
                } else if circle.state == .half {
                    draw(path: path, withColor: selectedColor, fillColor: unselectedFillColor, zValue: shapesZValue)
                } else {
                    draw(path: path, withColor: selectedColor, fillColor: selectedColor, zValue: shapesZValue)
                }
            }
        } else {
            for rectangle in rectanglesArr {
                let path = getRectanglePath(rectangle: rectangle, thickness: thickness)
                if rectangle.state == .empty {
                    draw(path: path, withColor: unselectedColor, fillColor: unselectedFillColor, zValue: shapesZValue)
                } else if rectangle.state == .half {
                    draw(path: path, withColor: selectedColor, fillColor: unselectedFillColor, zValue: shapesZValue)
                } else {
                    draw(path: path, withColor: selectedColor, fillColor: selectedColor, zValue: shapesZValue)
                }
            }
        }
        
        var lThickness = thickness
        if lineThickness >= 0 {
            lThickness = lineThickness
        }
        
        for line in linesArr {
            let path = getLinePath(line: line, thickness: thickness)
            if line.type == .incomplete {
                 draw(path: path, withColor: unselectedColor, fillColor: nil, lineThickness:lThickness, zValue: linesZValue)
            } else {
                draw(path: path, withColor: selectedColor, fillColor: nil, lineThickness:lThickness, zValue: linesZValue)
            }
        }
    }
    
    private func getCirclePath(circle: Circle, thickness: CGFloat) -> UIBezierPath {
        let circlePath = UIBezierPath(
            arcCenter: circle.center,
            radius: CGFloat(circle.radius - thickness/2),
            startAngle: CGFloat(0),
            endAngle:CGFloat(Double.pi * 2),
            clockwise: true)
        return circlePath
    }
    
    private func getRectanglePath(rectangle: Rectangle, thickness: CGFloat) -> UIBezierPath {
        let rectanglePath = UIBezierPath(roundedRect: rectangle.frame, cornerRadius: rectangle.cornerRaius)
        return rectanglePath
    }
    
    private func getLinePath(line: Line, thickness: CGFloat) -> UIBezierPath {
        let linePath = UIBezierPath()

        var start = line.start
        start.x -= thickness/4
        var end = line.end
        end.x += thickness/4
        
        linePath.move(to: start)
        linePath.addLine(to: end)
        return linePath
    }
    
    private func draw(path: UIBezierPath, withColor color: UIColor, fillColor: UIColor?, zValue: UInt32) {
        draw(path: path, withColor: color, fillColor: fillColor, lineThickness: thickness, zValue: zValue)
    }
    
    private func draw(path: UIBezierPath, withColor color: UIColor, fillColor: UIColor?, lineThickness: CGFloat, zValue: UInt32) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        if let fillColor = fillColor {
            shapeLayer.fillColor = fillColor.cgColor
        } else {
            shapeLayer.fillColor = UIColor.clear.cgColor
        }
        
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = lineThickness
        layer.insertSublayer(shapeLayer, at: zValue)
        layers.append(shapeLayer)
    }
    
    private func drawGradient(center: CGPoint, minRadius: CGFloat, maxRadius:CGFloat, fromColor: UIColor, toColor: UIColor) {
        let color1 = fromColor
        let color2 = toColor
        
        radGradientLayer = RadialGradientLayer.init(center: center, minRadius: minRadius, maxRadius: maxRadius, colors:  [color1.cgColor, color2.cgColor])
        
        radGradientLayer.frame = self.bounds
        radGradientLayer.setNeedsDisplay()
        layer.insertSublayer(radGradientLayer, at: gradientZValue)
        layers.append(radGradientLayer)
    }
}
