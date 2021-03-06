//
//  Constants.swift
//  FontShow
//
//  Created by 丁诚 on 16/6/9.
//  Copyright © 2016年 philipding. All rights reserved.
//

import Foundation

struct Constants {
  static let DefaultFontSize = 20
  static let DefaultValue = "Hello World & 中文样式"
  static let UserFontIndex = 0
  static let Port: UInt16 = 5506
  
  static var DocumentsPath: String? {
    get {
      let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
      return paths.first
    }
  }
}