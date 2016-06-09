//
//  SettingsViewController.swift
//  FontShow
//
//  Created by 丁诚 on 16/6/6.
//  Copyright © 2016年 philipding. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
  
  @IBOutlet weak var textLabel: UILabel!
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var fontSizeSlider: UISlider!
  @IBOutlet weak var fontSizeLabel: UILabel!
  
  var fontSize: Float = 20 {
    didSet {
      let size = Int(fontSize)
      textView.font = UIFont.systemFontOfSize(CGFloat(size))
      fontSizeSlider.value = Float(size)
      fontSizeLabel.text = "\(size) PT"
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    textLabel.text = NSLocalizedString("Free Text", comment: "")
    textView.text = Constants.DefaultValue
    fontSize = 20
  }
  
  @IBAction func valueChanged(sender: UISlider) {
    fontSize = sender.value
  }
}