//
//  HeaderView.swift
//  InterviewMe
//
//  Created by Alex Paul on 5/16/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit

class HeaderView: UICollectionReusableView {
  public lazy var promptLabel: UILabel = {
    let label = UILabel()
    return label
  }()
  
  public lazy var videoView: UIView = {
    let view = UIView()
    view.backgroundColor = .systemOrange
    return view
  }()
  
  override func layoutSubviews() {
    super.layoutSubviews()
    setupSubviews()
    backgroundColor = .systemBackground
  }
  
  public func configureHeaderView(for interview: Interview) {
    promptLabel.text = interview.prompt
  }
  
  private func setupSubviews() {
    setupPromptLabelConstraints()
    setupVideoViewConstraints()
  }
  
  private func setupPromptLabelConstraints() {
    addSubview(promptLabel)
    promptLabel.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      promptLabel.topAnchor.constraint(equalTo: topAnchor),
      promptLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
      promptLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
      promptLabel.heightAnchor.constraint(equalToConstant: 44)
    ])
  }
  
  private func setupVideoViewConstraints() {
    addSubview(videoView)
    videoView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      videoView.topAnchor.constraint(equalTo: promptLabel.bottomAnchor),
      videoView.leadingAnchor.constraint(equalTo: leadingAnchor),
      videoView.bottomAnchor.constraint(equalTo: bottomAnchor),
      videoView.trailingAnchor.constraint(equalTo: trailingAnchor)
    ])
  }
}
