//
//  FloatingButton.swift
//  InterviewMe
//
//  Created by Alex Paul on 5/16/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit

@IBDesignable
class FloatingButton: UIButton {
  
  @IBInspectable var cornerRadius: CGFloat = 0

  override func layoutSubviews() {
    super.layoutSubviews()
    layer.cornerRadius = cornerRadius
    layer.shadowOffset = CGSize(width: 0, height: 3)
    layer.shadowOpacity = 0.3
    layer.shadowRadius = 2
  }
}
