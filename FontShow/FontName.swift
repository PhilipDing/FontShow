
//
//  FontNames.swift
//  FontShow
//
//  Created by 丁诚 on 16/6/5.
//  Copyright © 2016年 philipding. All rights reserved.
//

import Foundation

struct FamilyName {
  var name: String
  var fontNames: [FontName]
}

struct FontName {
  var name: String
  var isChecked: Bool
}