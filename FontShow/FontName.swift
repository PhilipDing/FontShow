
//
//  FontNames.swift
//  FontShow
//
//  Created by 丁诚 on 16/6/5.
//  Copyright © 2016年 philipding. All rights reserved.
//

import Foundation

class FamilyName {
  var name: String
  var fontNames: [FontName]
  var userFont: Bool
  
  init(name: String, fontNames: [FontName]) {
    self.name = name
    self.fontNames = fontNames
    self.userFont = false
  }
  
  init(name: String, fontNames: [FontName], userFont: Bool) {
    self.name = name
    self.fontNames = fontNames
    self.userFont = userFont
  }
}

class FontName {
  var name: String
  var isChecked: Bool
  var selectable: Bool
  
  init(name: String) {
    self.name = name
    self.isChecked = false
    self.selectable = true
  }
  
  init(name: String, isChecked: Bool, selectable: Bool) {
    self.name = name
    self.isChecked = isChecked
    self.selectable = selectable
  }
}