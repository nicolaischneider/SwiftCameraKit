//
//  UIImageView+Helper.swift
//  100Questions
//
//  Created by Nicolai Schneider on 10.11.23.
//  Copyright © 2023 Schneider & co. All rights reserved.
//

import UIKit

extension UIButton {
    
    static func viewWithImage (
        image: UIImage?,
        tintColor: UIColor?,
        cornerRadius: CGFloat?,
        shadow: Bool,
        function: Selector?,
        tAMIC: Bool = false
    ) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.tintColor = tintColor
        button.backgroundColor = .clear
        if let cornerRadius {
            button.setCornerRadius(cornerRadius)
        }
        if shadow {
            button.setShadow()
        }
        if let function {
            button.addTarget(nil, action: function, for: .touchUpInside)
        }
        button.translatesAutoresizingMaskIntoConstraints = tAMIC
        return button
    }
    
    static func viewWithImage (
        image: String,
        tintColor: UIColor?,
        cornerRadius: CGFloat?,
        shadow: Bool,
        function: Selector?,
        tAMIC: Bool = false
    ) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: image), for: .normal)
        button.tintColor = tintColor
        button.backgroundColor = .clear
        if let cornerRadius {
            button.setCornerRadius(cornerRadius)
        }
        if shadow {
            button.setShadow()
        }
        if let function {
            button.addTarget(nil, action: function, for: .touchUpInside)
        }
        button.translatesAutoresizingMaskIntoConstraints = tAMIC
        return button
    }
    
    static func viewWithText (
        text: String?,
        color: UIColor,
        font: UIFont,
        cornerRadius: CGFloat?,
        shadow: Bool,
        function: Selector?,
        tAMIC: Bool = false
    ) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(text, for: .normal)
        button.setTitleColor(color, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.backgroundColor = .clear
        if let cornerRadius {
            button.setCornerRadius(cornerRadius)
        }
        if shadow {
            button.setShadow()
        }
        if let function {
            button.addTarget(nil, action: function, for: .touchUpInside)
        }
        button.translatesAutoresizingMaskIntoConstraints = tAMIC
        return button
    }
}


extension UIImageView {
    
    static func view(
        image: UIImage?,
        cornerRadius: CGFloat?,
        shadow: Bool,
        contentMode: UIView.ContentMode?,
        tAMIC: Bool = false
    ) -> UIImageView {
        let view = UIImageView()
        view.setAttributes(
            image: image,
            cornerRadius: cornerRadius,
            shadow: shadow,
            contentMode: contentMode,
            tAMIC: tAMIC)
        return view
    }
    
    static func view(
        imageName: String,
        cornerRadius: CGFloat?,
        shadow: Bool,
        contentMode: UIView.ContentMode?,
        tAMIC: Bool = false
    ) -> UIImageView {
        let view = UIImageView()
        view.setAttributes(
            image: UIImage(named: imageName),
            cornerRadius: cornerRadius,
            shadow: shadow,
            contentMode: contentMode,
            tAMIC: tAMIC)
        return view
    }
    
    private func setAttributes (
        image: UIImage?,
        cornerRadius: CGFloat?,
        shadow: Bool,
        contentMode: UIView.ContentMode?,
        tAMIC: Bool = false
    ) {
        self.image = image
        if let cornerRadius {
            self.setCornerRadius(cornerRadius)
            self.layer.masksToBounds = true
        } else {
            self.clipsToBounds = true
        }
        if shadow {
            self.setShadow()
        }
        if let contentMode {
            self.contentMode = contentMode
        }
        self.translatesAutoresizingMaskIntoConstraints = tAMIC
    }
}

extension UIView {
    
    static func viewClear() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    static func darkBackgroundView() -> UIView {
        return view(corner: nil, shadow: false, background: UIColor(white: 0, alpha: 0.5))
    }
    
    static func view(
        corner: CGFloat?,
        shadow: Bool,
        background: UIColor?,
        tAMIC: Bool = false
    ) -> UIView {
        let view = UIView()
        view.setViewAttributes(
            corner: corner,
            shadow: shadow,
            background: background,
            clipsToBounds: false,
            tAMIC: tAMIC)
        return view
    }
    
    static func view(
        corner: CGFloat?,
        shadow: Bool,
        background: UIColor?,
        clipsToBounds: Bool,
        tAMIC: Bool = false
    ) -> UIView {
        let view = UIView()
        view.setViewAttributes(
            corner: corner,
            shadow: shadow,
            background: background,
            clipsToBounds: clipsToBounds,
            tAMIC: tAMIC)
        return view
    }
    
    private func setViewAttributes (
        corner: CGFloat?,
        shadow: Bool,
        background: UIColor?,
        clipsToBounds: Bool,
        tAMIC: Bool
    ) {
        if let background {
            self.backgroundColor = background
        }
        if let corner {
            self.setCornerRadius(corner)
        }
        if shadow {
            self.setShadow()
        }
        self.clipsToBounds = clipsToBounds
        self.translatesAutoresizingMaskIntoConstraints = tAMIC
    }
}

extension UILabel {
    
    static func view (
        text: String?,
        font: UIFont?,
        color: UIColor,
        alignment: NSTextAlignment,
        shadow: Bool?,
        lines: Int?,
        tAMIC: Bool = false
    ) -> UILabel {
        let label = UILabel()
        label.setAttributes(
            text: text,
            font: font,
            color: color,
            shadow: shadow ?? false,
            lines: lines,
            tAMIC: tAMIC)
        label.backgroundColor = .clear
        label.textAlignment = alignment
        return label
    }
    
    static func viewWithBackground (
        text: String?,
        font: UIFont?,
        color: UIColor,
        background: UIColor,
        cornerRadius: CGFloat,
        shadow: Bool?,
        lines: Int?,
        tAMIC: Bool = false
    ) -> UILabel {
        let label = UILabel()
        label.setAttributes(
            text: text,
            font: font,
            color: color,
            shadow: shadow ?? false,
            lines: lines,
            tAMIC: tAMIC)
        label.backgroundColor = background
        label.textAlignment = .center
        label.setCornerRadius(cornerRadius)
        label.clipsToBounds = true
        return label
    }
    
    private func setAttributes (
        text: String?,
        font: UIFont?,
        color: UIColor,
        shadow: Bool,
        lines: Int?,
        tAMIC: Bool
    ) {
        if let text {
            self.text = text
        }
        self.textColor = color
        self.font = font
        if let lines {
            self.numberOfLines = lines
        }
        if shadow {
            self.setShadow()
        }
        self.translatesAutoresizingMaskIntoConstraints = tAMIC
    }
}




extension UIView {
    func setCornerRadius(_ value: CGFloat) {
        self.layer.cornerRadius = value
        self.layer.cornerCurve = .continuous
    }
     
    func setShadow () {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 7
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
}

extension UIView {
    func addTapGesture(button: UIButton, action: Selector) {
        button.removeAllGestureRecognizers()
        let tapGesture = UITapGestureRecognizer(target: self, action: action)
        button.addGestureRecognizer(tapGesture)
    }
    
    func removeAllGestureRecognizers() {
        if let gestureRecognizers = self.gestureRecognizers {
            gestureRecognizers.forEach { removeGestureRecognizer($0) }
        }
    }
}
