//
//  Interview.swift
//  InterviewMe
//
//  Created by Alex Paul on 5/16/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation

// DataPersistence is type constrained to only work
// with Codable and Equatable types
struct Interview: Codable & Equatable {
  let date = Date()
  let id = UUID().uuidString
  let prompt: String
  let videoData: Data
  let videoFileName: String
  let imageData: Data
  
  static func getPrompt() -> String {
    let prompts = ["What is GCD?",
                   "What is the difference between Synchronous & Asynchronous task",
                   "What is Enum or Enumerations",
                   "What is Hashable?",
                   "Explain AutoLayout",
                   "What is Encapsulation?",
                   "What’s the difference between the frame and the bounds",
                   "What is Singleton Pattern?",
                   "What is Continuous Integration?",
                   "What is big-o notation?",
                   "What is the difference Delegates and Callbacks?",
                   "What is CoreData?",
                   "How many different ways to pass data in Swift?",
                   "Explain MVC",
                   "What is Pointer?",
                   "Explain generics in Swift?",
                   "What kind of order functions can we use on collection types?",
                   "What is Concurrency?",
                   "What is the difference between a delegate and an NotificationCenter?",
                   "How is an inout parameter different from a regular parameter?",
    ]
    return prompts.randomElement() ?? "What is GCD?"
  }
}
