//
//  ViewController.swift
//  FontShow
//
//  Created by 丁诚 on 16/6/5.
//  Copyright © 2016年 philipding. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var searchBar: UISearchBar!
  
  var previewVC: PreviewViewController!
  var previewVCBySegue: PreviewViewController?
  
  var originalFamilyNames = [FamilyName]()
  var allFontNames = [FamilyName]()
  let connectionManager = ConnectionManager.sharedManager()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.title = NSLocalizedString("Font Show", comment: "")
    searchBar.placeholder = NSLocalizedString("Search", comment: "")
    tableView.estimatedRowHeight = 90
    tableView.rowHeight = UITableViewAutomaticDimension
    
    if let splitVC = self.splitViewController {
      previewVC = (splitVC.viewControllers[splitVC.viewControllers.count - 1] as! UINavigationController).topViewController as? PreviewViewController
    }
    
    loadFontsAndReloadTableData()
  }
  
  @IBAction func previewFontNames() {
    performSegueWithIdentifier("showDetail", sender: self)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showDetail" {
      if let navController = segue.destinationViewController as? UINavigationController {
        previewVCBySegue = navController.topViewController as? PreviewViewController
        previewVCBySegue?.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
        previewVCBySegue?.navigationItem.leftItemsSupplementBackButton = true
        previewVCBySegue?.fontSize = previewVC.fontSize
        previewVCBySegue?.text = previewVC.text
        previewVCBySegue?.previewFontNames = previewVC.previewFontNames
      }
    }
  }
}

// MARK: PRIVATE METHOD
extension MainViewController {
  func loadThirdPartyFonts(path: String) -> [FontName] {
    var fontNames = [FontName]()
    
    do {
      let contents = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(path)
      contents.forEach {
        let ocContent: NSString = $0
        let ocPath: NSString = path
        let ext = ocContent.pathExtension.lowercaseString
        if ext == "ttf" || ext == "otf" || ext == "ttc" {
          let fontName = FontName(name: ocContent.stringByDeletingPathExtension)
          fontName.url = ocPath.stringByAppendingPathComponent($0)
          fontNames.append(fontName)
        }
      }
    } catch {
      NSLog("exception when load third party font size from \(path)")
    }
    
    
    return fontNames
  }
  
  func loadThirdPartyFonts() {
    var fontNames = [FontName]()
    
    // load files from itunes
    if let itunesPath = Constants.DocumentsPath {
      fontNames += loadThirdPartyFonts(itunesPath)
    }
    
    // load files form wifi
    var wifiPath: NSString? = Constants.DocumentsPath
    wifiPath = wifiPath?.stringByAppendingPathComponent("upload")
    if let wifiPath = wifiPath as? String {
      fontNames += loadThirdPartyFonts(wifiPath)
    }
    
    if fontNames.count == 0 {
      fontNames.append(FontName(name: NSLocalizedString("Import Fonts from iTunes or Wifi", comment: ""), isChecked: false, seletable: false))
    }
    
    originalFamilyNames.insert(FamilyName(name: NSLocalizedString("User Font", comment: ""), fontNames: fontNames), atIndex: 0)
  }
  
  func loadSystemFonts() {
    let familyNames = UIFont.familyNames().sort()
    for familyName in familyNames {
      let temp = UIFont.fontNamesForFamilyName(familyName)
      let fontNames = temp.map { return FontName(name: $0) }
      originalFamilyNames.append(FamilyName(name: familyName, fontNames: fontNames))
    }
  }
  
  func loadFontsAndReloadTableData() {
    originalFamilyNames.removeAll()
    allFontNames.removeAll()
    
    self.loadThirdPartyFonts()
    self.loadSystemFonts()
    filterFonts(searchBar.text)
    
    tableView.reloadData()
  }
}

// MARK: TABLE VIEW DELEGATE & DATASOURCE
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
  
  struct TableConfiguration {
    static let SectionHeight: CGFloat = 44
    static let SectionHeaderBackgroundColor = UIColor(red: 222.0/255.0, green: 222.0/255.0, blue: 222.0/255.0, alpha: 1)
    static let SectionHeaderUserFontTextColor = UIColor(red: 35.0/255.0, green: 102.0/255.0, blue: 245.0/255.0, alpha: 1)
    static let SectionHeaderSystemFontTextColor = UIColor(red: 255.0/255.0, green: 54.0/255.0, blue: 94.0/255.0, alpha: 1)
    static let SubtitleCellPreviewFontSize: CGFloat = 17
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return allFontNames.count
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return allFontNames[section].fontNames.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let fontName = allFontNames[indexPath.section].fontNames[indexPath.row]
    let cell: FontNameCell
    if !fontName.seletable {
      cell = tableView.dequeueReusableCellWithIdentifier("basicCell", forIndexPath: indexPath) as! FontNameCell
      cell.previewTextLabel.text = NSLocalizedString("Import Fonts from iTunes or Wifi", comment: "")
      cell.selectionStyle = .None
    } else {
      cell = tableView.dequeueReusableCellWithIdentifier("subtitleCell", forIndexPath: indexPath) as! FontNameCell
      cell.previewTextLabel.text = Constants.DefaultValue
      
      if let fontUrl = fontName.url {
        cell.previewTextLabel.font = UIFont.fontWithURL(fontUrl, fontSize: TableConfiguration.SubtitleCellPreviewFontSize)
      } else {
        cell.previewTextLabel.font = UIFont(name: fontName.name, size: TableConfiguration.SubtitleCellPreviewFontSize)
      }
      
      cell.fontNameLabel.text = fontName.name
      cell.accessoryType = fontName.isChecked ? .Checkmark : .None
    }
    
    return cell
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return TableConfiguration.SectionHeight
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let fontName = allFontNames[section]

    let customView = UIView(frame: CGRect(x: 25, y: 0, width: tableView.bounds.width, height: TableConfiguration.SectionHeight))
    customView.backgroundColor = TableConfiguration.SectionHeaderBackgroundColor
    
    let label = UILabel(frame: customView.frame)
    label.opaque = false
    label.textColor = fontName.isUserFont ? TableConfiguration.SectionHeaderUserFontTextColor : TableConfiguration.SectionHeaderSystemFontTextColor
    label.font = UIFont(name: "Avenir", size: 18)
    label.text = fontName.name
    customView.addSubview(label)
    
    return customView
  }
  
  func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    let fontName = allFontNames[indexPath.section].fontNames[indexPath.row]
    return fontName.seletable ? indexPath : nil
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    let fontName = allFontNames[indexPath.section].fontNames[indexPath.row]
    var fontNames = previewVC.previewFontNames
    if fontName.isChecked {
      fontName.isChecked = false
      let removeIndex = fontNames.indexOf { $0.name == fontName.name }
      if let removeIndex = removeIndex {
        fontNames.removeAtIndex(removeIndex)
      }
    } else {
      fontName.isChecked = true
      let exits = fontNames.contains { $0.name == fontName.name && $0.url == fontName.url }
      if !exits {
        fontNames.append(fontName)
      }
    }
    
    previewVC.previewFontNames = fontNames
    previewVCBySegue?.previewFontNames = fontNames
    
    if let cell = tableView.cellForRowAtIndexPath(indexPath) {
      cell.accessoryType = cell.accessoryType == .None ? .Checkmark : .None
    }
    
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
}

// MARK: SEEARCH BAR DELEGATE
extension MainViewController: UISearchBarDelegate {
  
  func filterFonts(searchText: String?) {
    if let searchText = searchText where !searchText.isEmpty {
      allFontNames = originalFamilyNames.filter() {
        return $0.name.lowercaseString.containsString(searchText.lowercaseString)
          || $0.fontNames.contains({ (fontName) -> Bool in
            fontName.name.lowercaseString.containsString(searchText.lowercaseString)
          })
      }
    } else {
      allFontNames = originalFamilyNames
    }
  }
  
  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    filterFonts(searchText)
    tableView.reloadData()
  }
}

// MARK: NAVIGATION BAR ACTION
extension MainViewController {
  
  @IBAction func reload() {
    self.loadFontsAndReloadTableData()
  }
  
  @IBAction func startHttpServer() {
    
    let docURL: NSString? = NSBundle.mainBundle().pathForResource("index", ofType: "html", inDirectory: "web")
    if let docURL = docURL {
      self.connectionManager.startWithDocURL(docURL.stringByDeletingLastPathComponent, port: Constants.Port)
    }
    
    let ipAddress = DeviceInfo.ipAdress() + ": \(Constants.Port)"
    let message = String(format: NSLocalizedString("Wifi Upload Message", comment: ""), ipAddress)

    let alert = UIAlertController(title: NSLocalizedString("Wifi Upload", comment: ""), message: message, preferredStyle: .Alert)
    let action = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default) { action in
      self.connectionManager.stop()
      self.loadFontsAndReloadTableData()
    }
    alert.addAction(action)
    
    print(alert.view.subviews)

    self.presentViewController(alert, animated: true, completion: nil)
  }
}