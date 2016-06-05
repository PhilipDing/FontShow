//
//  ViewController.swift
//  FontShow
//
//  Created by 丁诚 on 16/6/5.
//  Copyright © 2016年 philipding. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var searchBar: UISearchBar!
  
  var allFontNames = [FamilyName]()
  var originalFamilyNames = [FamilyName]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.loadAllFonts()
    
    self.navigationItem.title = NSLocalizedString("Font Show", comment: "")
    searchBar.placeholder = NSLocalizedString("Search Family Name", comment: "")
    tableView.estimatedRowHeight = 50
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.reloadData()
  }
  
  func loadAllFonts() {
    let familyNames = UIFont.familyNames().sort()
    for familyName in familyNames {
      let temp = UIFont.fontNamesForFamilyName(familyName)
      let fontNames = temp.map { return FontName(name: $0, isChecked: false) }
      allFontNames.append(FamilyName(name: familyName, fontNames: fontNames))
    }
    
    originalFamilyNames = allFontNames
  }
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return allFontNames.count
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return allFontNames[section].fontNames.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
    let fontName = allFontNames[indexPath.section].fontNames[indexPath.row]
    cell.textLabel?.text = "Hello World 中文样式"
    cell.textLabel?.font = UIFont(name: fontName.name, size: 15)
    cell.detailTextLabel?.text = fontName.name
    cell.accessoryType = fontName.isChecked ? .Checkmark : .None
    
    return cell
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return allFontNames[section].name
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    allFontNames[indexPath.section].fontNames[indexPath.row].isChecked = true
    
    if let cell = tableView.cellForRowAtIndexPath(indexPath) {
      cell.accessoryType = cell.accessoryType == .None ? .Checkmark : .None
    }
    
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
}

extension ViewController: UISearchBarDelegate {
  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    
    if searchText.isEmpty {
      allFontNames = originalFamilyNames
    } else {
      allFontNames = originalFamilyNames.filter() {
        return $0.name.lowercaseString.containsString(searchText.lowercaseString)
          || $0.fontNames.contains({ (fontName) -> Bool in
            fontName.name.lowercaseString.containsString(searchText.lowercaseString)
          })
      }
    }
    tableView.reloadData()
  }
}






















