//
//  PreviewViewController.swift
//  FontShow
//
//  Created by 丁诚 on 16/6/6.
//  Copyright © 2016年 philipding. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {
  
  var previewFontNames: [FontName]!
  var fontSize: Int = 0 {
    didSet {
      fontSizeLabel.text = "\(fontSize) PT"
      tableView.reloadData()
    }
  }
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var fontSizeLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = NSLocalizedString("Preview", comment: "")
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Text", comment: ""), style: .Plain, target: self, action: #selector(PreviewViewController.showDefineText))
    tableView.estimatedRowHeight = 110
    tableView.rowHeight = UITableViewAutomaticDimension
    fontSize = 20
  }
  
  func showDefineText() {
    
  }
  
  @IBAction func fontSizeValueChanged(sender: UISlider) {
    fontSize = Int(sender.value)
  }
  
}

extension PreviewViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return previewFontNames.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("fontNameCell", forIndexPath: indexPath) as! FontNameCell
    let fontName = previewFontNames[indexPath.row]
    cell.fontNameLabel.text = fontName.name
    cell.previewTextLabel.text = "hehe"
    cell.previewTextLabel.font = UIFont(name: fontName.name, size: CGFloat(fontSize))
    
    return cell
  }
}
