//
//  UIFontExt.swift
//  FontShow
//
//  Created by 丁诚 on 16/6/9.
//  Copyright © 2016年 philipding. All rights reserved.
//

import UIKit
import CoreGraphics

extension UIFont {
  
  static func fontWithURL(fontPath: String, fontSize: CGFloat) -> UIFont? {
    let url = NSURL.fileURLWithPath(fontPath)
    let fontDataProvider = CGDataProviderCreateWithURL(url)
    if let newFont = CGFontCreateWithDataProvider(fontDataProvider),
      let newFontName = CGFontCopyPostScriptName(newFont) {
      CTFontManagerRegisterGraphicsFont(newFont, nil)
      
      return UIFont(name: String(newFontName), size: fontSize)
      
    }
    return nil
  }
}