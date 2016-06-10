//
//  PreviewViewController.swift
//  FontShow
//
//  Created by 丁诚 on 16/6/6.
//  Copyright © 2016年 philipding. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {
  
  var text: String = Constants.DefaultValue {
    didSet {
      tableView?.reloadData()
    }
  }
  
  var fontSize: Int = Constants.DefaultFontSize {
    didSet {
      tableView?.reloadData()
    }
  }
  
  var previewFontNames = [FontName]() {
    didSet {
      tableView?.reloadData()
    }
  }
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = NSLocalizedString("Preview", comment: "")
    tableView.estimatedRowHeight = 110
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.reloadData()
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "settings" {
      if let settingsVC = segue.destinationViewController as? SettingsViewController {
        settingsVC.popoverPresentationController?.delegate = self
        settingsVC.modalPresentationStyle = .Popover
        settingsVC.fontSize = fontSize
        settingsVC.text = text
        settingsVC.delegate = self
      }
    }
  }
}

extension PreviewViewController: UIPopoverPresentationControllerDelegate {
  
  func adaptivePresentationStyleForPresentationController(controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
    return .None
  }
}

extension PreviewViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return previewFontNames.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("fontNameCell", forIndexPath: indexPath) as! FontNameCell
    cell.backgroundColor = UIColor.clearColor()
    cell.contentView.backgroundColor = UIColor.clearColor()
    cell.containerView.layer.cornerRadius = 8
    cell.containerView.layer.borderColor = UIColor.grayColor().CGColor
    cell.containerView.layer.borderWidth = 1
    let fontName = previewFontNames[indexPath.row]
    cell.fontNameLabel.text = fontName.name
    cell.previewTextLabel.text = text
    
    if fontName.url != nil {
      cell.previewTextLabel.font = UIFont.fontWithURL(fontName.url!, fontSize: CGFloat(fontSize))
    } else {
      cell.previewTextLabel.font = UIFont(name: fontName.name, size: CGFloat(fontSize))
    }
    
    return cell
  }
}

extension PreviewViewController: SettingsViewControllerDelegate {
  func fontSizeDidChange(viewController: SettingsViewController) {
    fontSize = viewController.fontSize
  }

  func textDidChange(viewController: SettingsViewController) {
    text = viewController.text
  }
}
