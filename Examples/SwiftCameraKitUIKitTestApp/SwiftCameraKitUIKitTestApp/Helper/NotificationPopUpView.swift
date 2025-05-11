//
//  NotificationPopUpView.swift
//  100Questions
//
//  Created by knc on 20.12.23.
//  Copyright © 2023 Schneider & co. All rights reserved.
//

import UIKit
import SimpleConstraints

class NotificationPopUpView: UIView {
    
    let notificationBackground = UIView.view(
        corner: 12,
        shadow: false,
        background: UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 0.93))
    
    let notificationText = UILabel.view(
        text: nil,
        font: UIFont.systemFont(ofSize: 14),
        color: .white,
        alignment: .center,
        shadow: nil,
        lines: 0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showPopup(_ text: String) {
        configure(text: text)
        showNotification()
    }
    
    func configure (text: String) {
        notificationText.text = text
    }
    
    func showNotification () {
        self.animateNotification(alpha: 1)
        
        // wait 2.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2500), execute: {
            self.animateNotification(alpha: 0)
        })
    }
    
    // fade swiping notification out
    private func animateNotification (alpha: Int) {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = CGFloat(alpha)
        })
    }
    
    private func setupView() {
        unsafeConstraints(
            notificationBackground,
            constraints: [
                Straint(straint: .centerY, anchor: .centerY(self, 0)),
                Straint(straint: .height, anchor: .length(60)),
                Straint(straint: .left, anchor: .left(self, 15)),
                Straint(straint: .right, anchor: .right(self, -15))
            ])
        
        unsafeConstraints(
            notificationText,
            constraints: [
                Straint(straint: .centerY, anchor: .centerY(self, 0)),
                Straint(straint: .height, anchor: .length(60)),
                Straint(straint: .left, anchor: .left(self, 40)),
                Straint(straint: .right, anchor: .right(self, -40))
            ])
        
        // set alphas to zero
        alpha = 0
    }
}
