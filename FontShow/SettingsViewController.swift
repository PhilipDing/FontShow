//
//  SettingsViewController.swift
//  FontShow
//
//  Created by 丁诚 on 16/6/6.
//  Copyright © 2016年 philipding. All rights reserved.
//

import UIKit

protocol SettingsViewControllerDelegate {
  func fontSizeDidChange(viewController: SettingsViewController)
  func textDidChange(viewController: SettingsViewController)
}

class SettingsViewController: UIViewController {
  
  var delegate: SettingsViewControllerDelegate?
  @IBOutlet weak var textLabel: UILabel!
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var fontSizeSlider: UISlider!
  @IBOutlet weak var fontSizeLabel: UILabel!
  
  var fontSize: Int! {
    didSet {
      textView?.font = UIFont.systemFontOfSize(CGFloat(fontSize))
      fontSizeSlider?.value = Float(fontSize)
      fontSizeLabel?.text = "\(fontSize) PT"
    }
  }
  
  var text: String! {
    didSet {
      if textView?.text != text {
        textView?.text = text
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    textLabel.text = NSLocalizedString("Free Text", comment: "")
    textView.text = text
    textView.font = UIFont.systemFontOfSize(CGFloat(fontSize))
    fontSizeSlider.value = Float(fontSize)
    fontSizeLabel.text = "\(fontSize) PT"
  }
  
  @IBAction func valueChanged(sender: UISlider) {
    fontSize = Int(sender.value)
    delegate?.fontSizeDidChange(self)
  }
}

extension SettingsViewController: UITextViewDelegate {
  func textViewDidChange(textView: UITextView) {
    text = textView.text
    delegate?.textDidChange(self)
  }
}