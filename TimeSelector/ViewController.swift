//
//  ViewController.swift
//  TimeSelector
//
//  Created by Chris Galzerano on 12/18/18.
//  Copyright © 2018 chrisgalz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var selectedTime: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let tap = UILabel(frame: self.view.bounds)
        tap.textAlignment = .center
        tap.text = "Tap to display picker\n\nSelected Time"
        tap.numberOfLines = 0
        tap.lineBreakMode = .byWordWrapping
        tap.center.y -= 25
        self.view.addSubview(tap)
        
        selectedTime = UILabel(frame: self.view.bounds)
        selectedTime.textAlignment = .center
        selectedTime.text = "None"
        selectedTime.center.y += 25
        self.view.addSubview(selectedTime)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showPicker))
        self.view.addGestureRecognizer(tapGesture)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showPicker()
    }
    
    @objc func showPicker() {
        let timeSelector = TimeSelector()
        timeSelector.timeSelected = {
            (timeSelector) in
            self.setLabelFromDate(timeSelector.date)
        }
        timeSelector.overlayAlpha = 0.8
        timeSelector.clockTint = timeSelector_rgb(0, 230, 0)
        timeSelector.minutes = 30
        timeSelector.hours = 5
        timeSelector.isAm = false
        timeSelector.presentOnView(view: self.view)
    }
    
    func setLabelFromDate(_ date: Date) {
        let df = DateFormatter()
        df.dateStyle = .none
        df.timeStyle = .long
        selectedTime.text = df.string(from: date)
    }

}

