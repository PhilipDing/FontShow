
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
  
  init(name: String, fontNames: [FontName]) {
    self.name = name
    self.fontNames = fontNames
  }
}

class FontName {
  var name: String
  var isChecked: Bool
  var seletable: Bool
  
  init(name: String) {
    self.name = name
    self.isChecked = false
    self.seletable = true
  }
  
  init(name: String, isChecked: Bool, seletable: Bool) {
    self.name = name
    self.isChecked = isChecked
    self.seletable = seletable
  }
}