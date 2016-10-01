//
//  TodayViewController.swift
//  AppleDeveloperNews
//
//  Created by MehulS on 01/10/16.
//  Copyright © 2016 MehulS. All rights reserved.
//


//Reference for Today Extension : http://www.appcoda.com/app-extension-programming-today/

import UIKit
import NotificationCenter

//New URL
let URL_NEWS = "https://developer.apple.com/news/rss/news.rss"
let SIZE_EXPANDED = 275
let SIZE_COMPACT = 110

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDataSource, UITableViewDelegate, XMLParserDelegate {
    
    @IBOutlet weak var tableViewNews: UITableView!
    @IBOutlet weak var constraintTableViewHeight: NSLayoutConstraint!
    
    var xmlParser = XMLParser()
    var arrayNews = NSMutableArray()
    var dicData = NSMutableDictionary()
    var strElement = String()
    var strTitle = String()
    var strLink = String()
    var strDescription = String()
    var strDate = String()
    var isNeedToGetItemData = false
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        //For Show more/less button
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        
        //TableView with 2 records at starting
        //constraintTableViewHeight.constant = 275
        self.preferredContentSize = CGSize(width: 0, height: SIZE_EXPANDED)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Call method to start parsing news feeds
        self.parseNewsFeeds()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        //Show more/less button event
        if (activeDisplayMode == NCWidgetDisplayMode.compact) {
//            constraintTableViewHeight.constant = 110
            self.preferredContentSize = CGSize(width: 0, height: SIZE_COMPACT)
        }else {
//            if arrayNews.count >= 5 {
//                constraintTableViewHeight.constant = 275
//            }else {
//                constraintTableViewHeight.constant = CGFloat(arrayNews.count * 55)
//            }
            self.preferredContentSize = CGSize(width: 0, height: SIZE_EXPANDED)
        }
        //self.preferredContentSize = CGSize(width: 0, height: constraintTableViewHeight.constant)
    }
    
    //MARK: - Parse New Feeds
    func parseNewsFeeds() {
        let URL = NSURL(string: URL_NEWS)
        xmlParser = XMLParser(contentsOf: URL as! URL)!
        xmlParser.delegate = self
        xmlParser.parse()
    }
    
    //MARK: - XMLParser Delegates
    func parserDidStartDocument(_ parser: XMLParser) {
        //Start Parsing
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        strElement = elementName
        if strElement == "item" {
            isNeedToGetItemData = true
            
            //Re-initialise
            dicData = NSMutableDictionary()
            strTitle = String()
            strLink = String()
            strDescription = String()
            strDate = String()
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if isNeedToGetItemData == true && string != "\n" {
            if strElement == "title" {
                strTitle.append(string)
            }else if strElement == "link" {
                strLink.append(string)
            }else if strElement == "description" {
                strDescription.append(string)
            }else if strElement == "pubDate" {
                strDate.append(string)
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            dicData.setValue(strTitle, forKey: "title")
            dicData.setValue(strLink, forKey: "link")
            dicData.setValue(strDescription, forKey: "description")
            dicData.setValue(strDate, forKey: "pubDate")
            
            //Add to final array
            arrayNews.add(dicData)
            
            //make this flag FALSE
            isNeedToGetItemData = false
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        //End Parsing : Reload Table
        if arrayNews.count > 0 {
            self.tableViewNews.reloadData()
        }
        
        //print(arrayNews)
    }
    
    
    //MARK: - UITableView Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayNews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CellNews"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as UITableViewCell?
        
        //Cell properties
        cell?.selectionStyle = .none
        
        let dicNews = arrayNews.object(at: indexPath.row) as! NSDictionary
        
        cell?.imageView?.image = UIImage(named: "News")
        cell?.textLabel?.text = dicNews.value(forKey: "title") as? String
        cell?.textLabel?.numberOfLines = 2
        cell?.textLabel?.lineBreakMode = .byWordWrapping
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Open link to SAFARI
        let strLink = (arrayNews.object(at: indexPath.row) as! NSDictionary).value(forKey: "link")
        print(strLink!)
        
        self.extensionContext?.open(URL(string: strLink as! String)!, completionHandler: { (isFinished) in
            print("Link Open")
        })
        
        //UIApplication.shared.openURL(URL(string: strLink as! String)!)
    }
    
}
