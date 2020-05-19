//
//  VideoCell.swift
//  InterviewMe
//
//  Created by Alex Paul on 5/16/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit

protocol VideoCellDelegate: AnyObject {
  func didSelectInterview(_ cell: VideoCell, interview: Interview)
}

class VideoCell: UICollectionViewCell {

  @IBOutlet weak var promptLabel: UILabel!
  @IBOutlet weak var videoThumbnail: UIImageView!
  
  private lazy var longPressGesture: UILongPressGestureRecognizer = {
    let gesture = UILongPressGestureRecognizer()
    gesture.addTarget(self, action: #selector(handleLongPress(_:)))
    return gesture
  }()
  
  private var currentInterview: Interview!
  private var isLongPressActive = false

  weak var delegate: VideoCellDelegate?
  
  override func layoutSubviews() {
    super.layoutSubviews()
    addGestureRecognizer(longPressGesture)
  }
  
  public func configureCell(for interview: Interview) {
    currentInterview = interview
    promptLabel.text = interview.prompt
    videoThumbnail.image = UIImage(data: interview.imageData)
  }
  
  @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
    switch gesture.state {
    case .began:
      if isLongPressActive { return }
      delegate?.didSelectInterview(self, interview: currentInterview)
      isLongPressActive = true
    default:
      isLongPressActive = false
    }
  }
  
}
