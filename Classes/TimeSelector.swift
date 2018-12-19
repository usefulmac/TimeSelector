//Copyright 2018 Chris Galzerano, Playr Inc., CarMeets Inc.

//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//
//  TimeSelector.swift
//  CarMeets
//
//  Created by Chris Galzerano on 12/18/18.
//  Copyright © 2018 Zachary Khan. All rights reserved.
//

import UIKit

func timeSelector_rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> UIColor {
    let tc: CGFloat = 255.0
    return UIColor.init(red: r/tc, green: g/tc, blue: b/tc, alpha: 1.0)
}

func CGRekt(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
    return CGRect(x: x, y: y, width: width, height: height)
}

extension CGRect {
    func bottom() -> CGFloat {
        return origin.y+size.height
    }
    func right() -> CGFloat {
        return origin.x+size.width
    }
}

class TimeSelector: UIView {
    
    private var overlay: UIVisualEffectView!
    private var container: UIView!
    private var headerView: UIView!
    private var timeCircle: UIView!
    
    private let containerSize = CGSize(width: UIScreen.main.bounds.width*0.7, height: UIScreen.main.bounds.height*0.6)
    private let headerHeight: CGFloat = 110.0
    private let timeCirclePadding: CGFloat = 30.0
    private var circleSize: CGFloat = 0
    
    private var hoursLabel: UILabel!
    private var colonLabel: UILabel!
    private var minutesLabel: UILabel!
    
    private var amLabel: UILabel!
    private var pmLabel: UILabel!
    
    private var okButton: UIButton!
    
    private var cancelButton: UIButton!
    
    private var selectorCircle: UIView!
    private var selectorLine: CAShapeLayer!
    private var selectorDot: UIView!
    private var centerCircle: UIView!
    
    private var hourLabels: [UILabel] = []
    private var minuteLabels: [UILabel] = []
    
    private let grayTextColor = timeSelector_rgb(189, 189, 189)
    
    private var needsTimeRefresh = true
    
    var timeSelected: (_ timeSelector: TimeSelector) -> Void = {_ in}
    var overlayAlpha: CGFloat = 0.9
    var clockTint: UIColor = timeSelector_rgb(0, 230, 0) {
        didSet {
            selectorCircle.backgroundColor = clockTint
            centerCircle.backgroundColor = clockTint
            selectorLine.strokeColor = clockTint.cgColor
        }
    }
    
    //When setting time components externally:
    //Before presenting, set hours after minutes.
    
    var hours: Int = 0 {
        didSet {
            print("setHours: \(hours)")
            let last = isMinutes
            isMinutes = false
            setLineToPoint(pointForArcByIndex(index: CGFloat(hours)))
            if needsTimeRefresh == true {
                setTimeFromIndex(CGFloat(hours))
            }
            isMinutes = last
        }
    }
    
    var minutes: Int = 0 {
        didSet {
            let last = isMinutes
            isMinutes = true
            let min = CGFloat(minutes)/5.0
            setLineToPoint(pointForArcByIndex(index: min))
            if needsTimeRefresh == true {
                setTimeFromIndex(min)
            }
            isMinutes = last
        }
    }
    
    var isAm: Bool = true {
        didSet {
            if isAm == false {
                amLabel.textColor = grayTextColor
                pmLabel.textColor = .white
            }
            else {
                amLabel.textColor = .white
                pmLabel.textColor = grayTextColor
            }
        }
    }
    
    var date: Date {
        set {
            let cal = Calendar.current
            var h = cal.component(Calendar.Component.hour, from: newValue)
            let m = cal.component(Calendar.Component.minute, from: newValue)
            minutes = m
            if h > 12 {
                isAm = false
                h -= 12
            }
            else {
                isAm = true
            }
            if h == 0 {
                h = 12
            }
            hours = h
        }
        get {
            let cal = Calendar.current
            var h = hours
            if isAm == false {
                h += 12
            }
            let date = Date()
            if h == 24 {
                h = 12
            }
            return cal.date(bySettingHour: h, minute: minutes, second: 0, of: date)!
        }
    }
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        
        let effect = UIBlurEffect(style: .dark)
        overlay = UIVisualEffectView(effect: effect)
        overlay.frame = self.bounds
        self.addSubview(overlay)
        
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        overlay.contentView.addGestureRecognizer(dismissTap)
        
        container = UIView(frame: CGRekt((self.frame.size.width-containerSize.width)/2.0, (self.frame.size.height-containerSize.height)/2.0, containerSize.width, containerSize.height))
        container.backgroundColor = timeSelector_rgb(66, 66, 66)
        self.addSubview(container)
        
        headerView = UIView(frame: CGRekt(0, 0, containerSize.width, headerHeight))
        headerView.backgroundColor = timeSelector_rgb(85, 85, 85)
        container.addSubview(headerView)
        
        circleSize = containerSize.width-(timeCirclePadding*2.0)
        lineCenter = CGPoint(x: circleSize/2.0, y: circleSize/2.0)
        timeCircle = UIView(frame: CGRekt(timeCirclePadding, timeCirclePadding+headerView.frame.bottom(), circleSize, circleSize))
        timeCircle.layer.cornerRadius = circleSize/2.0
        timeCircle.layer.masksToBounds = true
        timeCircle.backgroundColor = headerView.backgroundColor
        container.addSubview(timeCircle)
        
        selectorLine = CAShapeLayer.init()
        selectorLine.strokeColor = clockTint.cgColor
        selectorLine.lineWidth = 2.0
        selectorLine.fillColor = nil
        selectorLine.opacity = 1.0
        timeCircle.layer.addSublayer(selectorLine)
        
        let selectorSize: CGFloat = 40.0
        selectorCircle = UIView(frame: CGRekt(0, 0, selectorSize, selectorSize))
        selectorCircle.center = pointForArcByIndex(index: 0)
        selectorCircle.backgroundColor = clockTint
        selectorCircle.layer.cornerRadius = selectorSize/2.0
        selectorCircle.layer.masksToBounds = true
        timeCircle.addSubview(selectorCircle)
        
        let dotSize: CGFloat = 4.0
        let insetDot: CGFloat = (selectorSize-dotSize)/2.0
        selectorDot = UIView(frame: CGRekt(insetDot, insetDot, dotSize, dotSize))
        selectorDot.backgroundColor = .black
        selectorDot.layer.cornerRadius = dotSize/2.0
        selectorDot.layer.masksToBounds = true
        selectorDot.isHidden = true
        selectorCircle.addSubview(selectorDot)
        
        setLineToPoint(pointForArcByIndex(index: 0))
        
        let centerCircleSize: CGFloat = 8.0
        let ccInset: CGFloat = (circleSize-centerCircleSize)/2.0
        centerCircle = UIView(frame: CGRekt(ccInset, ccInset, centerCircleSize, centerCircleSize))
        centerCircle.backgroundColor = clockTint
        centerCircle.layer.cornerRadius = centerCircleSize/2.0
        centerCircle.layer.masksToBounds = true
        timeCircle.addSubview(centerCircle)
        
        initializeClockLabels()
        
        let labelPadding: CGFloat = 35.0
        let labelFont = UIFont.systemFont(ofSize: 60.0)
        let timeLabelWidth: CGFloat = 100.0
        let colonLabelWidth: CGFloat = 18.0
        let labelPaddingY: CGFloat = 20.0
        
        hoursLabel = UILabel(frame: CGRekt(containerSize.width-labelPadding-(timeLabelWidth*2.0)-colonLabelWidth, labelPaddingY, timeLabelWidth, headerHeight-(labelPaddingY*2.0)))
        hoursLabel.text = "12"
        hoursLabel.textColor = .white
        hoursLabel.font = labelFont
        hoursLabel.textAlignment = .right
        hoursLabel.isUserInteractionEnabled = true
        headerView.addSubview(hoursLabel)
        
        let hoursTap = UITapGestureRecognizer(target: self, action: #selector(setForHours))
        hoursLabel.addGestureRecognizer(hoursTap)
        
        let colonLabel = UILabel(frame: CGRekt(hoursLabel.frame.right(), labelPaddingY, colonLabelWidth, hoursLabel.frame.size.height))
        colonLabel.font = labelFont
        colonLabel.textColor = grayTextColor
        colonLabel.textAlignment = .center
        colonLabel.text = ":"
        headerView.addSubview(colonLabel)
        
        minutesLabel = UILabel(frame: CGRekt(colonLabel.frame.right(), labelPaddingY, timeLabelWidth-25, hoursLabel.frame.size.height))
        minutesLabel.text = "00"
        minutesLabel.textColor = grayTextColor
        minutesLabel.font = labelFont
        minutesLabel.textAlignment = .left
        minutesLabel.isUserInteractionEnabled = true
        headerView.addSubview(minutesLabel)
        
        let minutesTap = UITapGestureRecognizer(target: self, action: #selector(setForMinutes))
        minutesLabel.addGestureRecognizer(minutesTap)
        
        setLineToPoint(pointForArcByIndex(index: 9))
        
        let amPmFont = UIFont.boldSystemFont(ofSize: 16.0)
        let amPmWidth: CGFloat = 50.0
        
        amLabel = UILabel(frame: CGRekt(container.frame.size.width-(amPmWidth*1.25), 32, amPmWidth, 25.0))
        amLabel.text = "AM"
        amLabel.textColor = .white
        amLabel.textAlignment = .center
        amLabel.font = amPmFont
        amLabel.isUserInteractionEnabled = true
        headerView.addSubview(amLabel)
        
        let amTap = UITapGestureRecognizer(target: self, action: #selector(switchAm))
        amLabel.addGestureRecognizer(amTap)
        
        pmLabel = UILabel(frame: CGRekt(container.frame.size.width-(amPmWidth*1.25), amLabel.frame.bottom(), amPmWidth, amLabel.frame.size.height))
        pmLabel.text = "PM"
        pmLabel.textColor = grayTextColor
        pmLabel.textAlignment = .center
        pmLabel.font = amPmFont
        pmLabel.isUserInteractionEnabled = true
        headerView.addSubview(pmLabel)
        
        let pmTap = UITapGestureRecognizer(target: self, action: #selector(switchPm))
        pmLabel.addGestureRecognizer(pmTap)
        
        let buttonFont = UIFont.boldSystemFont(ofSize: 14.0)
        let buttonHeight: CGFloat = 55.0
        let buttonWidth: CGFloat = 80.0
        
        cancelButton = UIButton(type: .system)
        cancelButton.setTitle("CANCEL", for: .normal)
        cancelButton.titleLabel?.font = buttonFont
        cancelButton.tintColor = .white
        cancelButton.frame = CGRekt(container.frame.size.width-(buttonWidth*2.0), containerSize.height-buttonHeight, buttonWidth, buttonHeight)
        cancelButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        container.addSubview(cancelButton)
        
        okButton = UIButton(type: .system)
        okButton.setTitle("OK", for: .normal)
        okButton.titleLabel?.font = buttonFont
        okButton.tintColor = .white
        okButton.frame = CGRekt(cancelButton.frame.right(), cancelButton.frame.origin.y, cancelButton.frame.size.width, buttonHeight)
        okButton.addTarget(self, action: #selector(selectDate), for: .touchUpInside)
        container.addSubview(okButton)
        
    }
    
    @objc func selectDate() {
        self.timeSelected(self)
        dismiss()
    }
    
    var isMinutes = false {
        didSet {
            if isMinutes == false {
                selectorDot.isHidden = true
            }
        }
    }
    
    private var lineCenter: CGPoint = .zero
    
    func pathForPoint(_ point: CGPoint) -> UIBezierPath {
        let path = UIBezierPath.init()
        path.move(to: lineCenter)
        path.addLine(to: point)
        return path
    }
    
    private var linePoint: CGPoint? = nil
    
    func setLineToPoint(_ point: CGPoint) {
        linePoint = point
        selectorLine.path = pathForPoint(point).cgPath
        selectorCircle.center = point
    }
    
    func clockLabel() -> UILabel {
        let itemSize: CGFloat = 50.0
        let label = UILabel(frame: CGRekt(0, 0, itemSize, itemSize))
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }
    
    func initializeClockLabels() {
        for i in 1...12 {
            let hourLabel = clockLabel()
            hourLabel.text = "\(i)"
            hourLabel.center = pointForArcByIndex(index: CGFloat(i))
            timeCircle.addSubview(hourLabel)
            hourLabels.append(hourLabel)
            
            let minuteLabel = clockLabel()
            minuteLabel.text = "\((i-1)*5)"
            minuteLabel.center = pointForArcByIndex(index: CGFloat(i-1))
            minuteLabel.alpha = 0
            timeCircle.addSubview(minuteLabel)
            minuteLabels.append(minuteLabel)
        }
    }
    
    func circleDetails(_ index: CGFloat = 0) -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        let itemCount: CGFloat = 12.0
        let inset: CGFloat = 10.0
        let radius = (circleSize/2.0)-inset
        let const: CGFloat = 4.0
        let small = CGFloat(itemCount)*(const/8.0)
        let smallAngle = const/small
        let adjustment = radius/small
        let smallerRadius = radius-adjustment
        let angle = (CGFloat(Double.pi)/const)*smallAngle*CGFloat(index)
        return (smallerRadius, angle, adjustment, inset)
    }
    
    func pointForArcByIndex(index: CGFloat) -> CGPoint {
        let (smallerRadius, angle, adjustment, inset) = circleDetails(index)
        let x: CGFloat = smallerRadius + smallerRadius*CGFloat(sinf(Float(angle)))
        let y: CGFloat = smallerRadius * CGFloat((1 - cosf(Float(angle))))
        return CGPoint(x: x+adjustment+inset, y: y+adjustment+inset)
    }
    
    private var lastLocation: CGPoint? = nil
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            lastLocation = touch.location(in: timeCircle)
        }
    }
    
    func radiansBetweenPoint(_ location: CGPoint, _ last: CGPoint) -> CGFloat {
        let radius: CGFloat = circleSize/2.0
        let deltaX = location.x - radius;
        let deltaY = location.y - radius;
        let rad = CGFloat(atan2(deltaY, deltaX));
        return rad
    }
    
    private var lastIndex: CGFloat? = nil
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: timeCircle)
            let extraGrip: CGFloat = -25.0
            if let last = lastLocation, location.x > extraGrip, location.y > extraGrip {
                let rad = radiansBetweenPoint(location, last)
                let value = (CGFloat(rad)/CGFloat.pi)*180
                let currentAngle: CGFloat = ((radiansBetweenPoint(lineCenter, linePoint!)/CGFloat.pi)*180.0)-90.0
                let newValue = value+currentAngle+180.0
                var index: CGFloat = (newValue/360.0)*12
                if roundf(Float(index)) <= 0 {
                    index += 12
                }
                setLineToPoint(pointForArcByIndex(index: index))
                setTimeFromIndex(index)
                lastIndex = index
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let last = self.lastIndex {
            if self.isMinutes == true {
                let newIndex = CGFloat(roundf(Float(last*5.0)))/5.0
                self.setLineToPoint(self.pointForArcByIndex(index: newIndex))
            }
            else {
                self.setLineToPoint(self.pointForArcByIndex(index: CGFloat(roundf(Float(last)))))
                setForMinutes()
            }
        }
    }
    
    @objc func setForHours() {
        isMinutes = false
        switchViews()
        hoursLabel.textColor = .white
        minutesLabel.textColor = grayTextColor
        selectorDot.isHidden = true
        setLineToPoint(pointForArcByIndex(index: CGFloat(hours)))
    }
    
    @objc func setForMinutes() {
        isMinutes = true
        switchViews()
        hoursLabel.textColor = grayTextColor
        minutesLabel.textColor = .white
        let min = CGFloat(minutes)/5.0
        selectorDot.isHidden = minutes%5 != 0 ? false : true
        setLineToPoint(pointForArcByIndex(index: min))
    }
    
    @objc func switchAm() {
        isAm = true
    }
    
    @objc func switchPm() {
        isAm = false
    }
    
    @objc func switchViews() {
        UIView.animate(withDuration: 0.3) {
            for view in self.hourLabels {
                view.alpha = self.isMinutes == true ? 0 : 1.0
            }
            for view in self.minuteLabels {
                view.alpha = self.isMinutes == false ? 0 : 1.0
            }
        }
    }
    
    func setTimeFromIndex(_ index: CGFloat) {
        if isMinutes == true {
            var value = Int(roundf(Float(index*5.0)))
            if value >= 60 {
                value -= 60
            }
            var extra = ""
            if value < 10 {
                extra = "0"
            }
            needsTimeRefresh = false
            minutes = value
            needsTimeRefresh = true
            minutesLabel.text = "\(extra)\(value)"
            selectorDot.isHidden = value%5 != 0 ? false : true
        }
        else {
            let value = Int(roundf(Float(index)))
            needsTimeRefresh = false
            hours = value
            needsTimeRefresh = true
            hoursLabel.text = "\(value)"
        }
    }
    
    func presentOnView(view: UIView) {
        container.transform = CGAffineTransform(translationX: 0, y: -1*UIScreen.main.bounds.size.height)
        overlay.alpha = 0
        view.window?.addSubview(self)
        UIView.animate(withDuration: 0.3, animations: {
            self.overlay.alpha = self.overlayAlpha
        }) { (finished) in
            if finished == true {
                UIView.animate(withDuration: 0.3, animations: {
                    self.container.transform = .identity
                })
            }
        }
    }
    
    @objc func dismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            self.container.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.size.height)
        }) { (finished) in
            if finished == true {
                UIView.animate(withDuration: 0.3, animations: {
                    self.overlay.alpha = 0
                }) { (finished) in
                    if finished == true {
                        self.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
