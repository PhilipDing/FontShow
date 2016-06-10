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
    
    self.loadThirdPartyFonts()
    self.loadAllFonts()
    originalFamilyNames = allFontNames
    
    self.navigationItem.title = NSLocalizedString("Font Show", comment: "")
    searchBar.placeholder = NSLocalizedString("Search", comment: "")
    tableView.estimatedRowHeight = 50
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.reloadData()
    
    if let splitVC = self.splitViewController {
      previewVC = (splitVC.viewControllers[splitVC.viewControllers.count - 1] as! UINavigationController).topViewController as? PreviewViewController
    }
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
      NSLog("exception when load third party font size", "")
    }
    
    
    return fontNames
  }
  
  func loadThirdPartyFonts() {
    var fontNames = [FontName]()
    
    // load files from itunes
    let itunesPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
    if let itunesPath = itunesPaths.first {
      fontNames += loadThirdPartyFonts(itunesPath)
    }
    
    // load files form wifi
    var wifiPath: NSString? = NSBundle.mainBundle().pathForResource("index", ofType: "html", inDirectory: "web")
    wifiPath = wifiPath?.stringByDeletingLastPathComponent
    wifiPath = wifiPath?.stringByAppendingPathComponent("upload")
    
    print(wifiPath)
    if let wifiPath = wifiPath as? String {
      fontNames += loadThirdPartyFonts(wifiPath)
    }
    
    if fontNames.count == 0 {
      fontNames.append(FontName(name: NSLocalizedString("Import Fonts from iTunes or Wifi", comment: ""), isChecked: false, seletable: false))
    }
    
    allFontNames.insert(FamilyName(name: NSLocalizedString("User Font", comment: ""), fontNames: fontNames), atIndex: 0)
  }
  
  func loadThirdPartyFontsAndReloadTableData() {
    allFontNames.removeFirst()
    loadThirdPartyFonts()
    tableView.reloadData()
  }
  
  func loadAllFonts() {
    let familyNames = UIFont.familyNames().sort()
    for familyName in familyNames {
      let temp = UIFont.fontNamesForFamilyName(familyName)
      let fontNames = temp.map { return FontName(name: $0) }
      allFontNames.append(FamilyName(name: familyName, fontNames: fontNames))
    }
  }
}

// MARK: TABLE VIEW DELEGATE & DATASOURCE
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return allFontNames.count
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return allFontNames[section].fontNames.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let fontName = allFontNames[indexPath.section].fontNames[indexPath.row]
    let cell: UITableViewCell
    if !fontName.seletable {
      cell = tableView.dequeueReusableCellWithIdentifier("basicCell", forIndexPath: indexPath)
      cell.textLabel?.text = NSLocalizedString("Import Fonts from iTunes", comment: "")
      cell.selectionStyle = .None
    } else {
      cell = tableView.dequeueReusableCellWithIdentifier("subtitleCell", forIndexPath: indexPath)
      cell.textLabel?.text = Constants.DefaultValue
      if indexPath.section == Constants.UserFontIndex {
        cell.textLabel?.font = UIFont.fontWithURL(fontName.url!, fontSize: 15)
      } else {
        cell.textLabel?.font = UIFont(name: fontName.name, size: 15)
      }
      cell.detailTextLabel?.text = fontName.name
      cell.accessoryType = fontName.isChecked ? .Checkmark : .None
    }
    
    return cell
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return allFontNames[section].name
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let fontName = allFontNames[section]
    let customView = UIView(frame: CGRect(x: 15, y: 0, width: tableView.bounds.width, height: 30))
    customView.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1)
    let label = UILabel(frame: customView.frame)
    label.opaque = false
    if section == Constants.UserFontIndex {
      label.textColor = UIColor(red: 35.0/255.0, green: 102.0/255.0, blue: 245.0/255.0, alpha: 1)
    } else {
      label.textColor = UIColor(red: 255.0/255.0, green: 54.0/255.0, blue: 94.0/255.0, alpha: 1)
    }
    
    label.font = UIFont.systemFontOfSize(18)
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
      fontNames.append(fontName)
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

// MARK: NAVIGATION BAR ACTION
extension MainViewController {
  
  @IBAction func reload() {
    self.loadThirdPartyFontsAndReloadTableData()
  }
  
  @IBAction func startHttpServer() {
    
    let docURL: NSString? = NSBundle.mainBundle().pathForResource("index", ofType: "html", inDirectory: "web")
    if let docURL = docURL {
      self.connectionManager.startWithDocURL(docURL.stringByDeletingLastPathComponent, port: Constants.Port)
    }
    
    let ip = DeviceInfo.ipAdress() + ": \(Constants.Port)"
    let message = "上传过程中请勿离开此页或锁屏 \r\n 在电脑浏览器地址栏输入 \r\n \(ip)"
    let alert = UIAlertController(title: NSLocalizedString("Wifi Uploads", comment: ""), message: message, preferredStyle: .Alert)
    let action = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default) { action in
      self.connectionManager.stop()
      self.loadThirdPartyFontsAndReloadTableData()
    }
    alert.addAction(action)

    self.presentViewController(alert, animated: true, completion: nil)
  }
}