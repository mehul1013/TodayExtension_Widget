//
//  ViewController.swift
//  WidgetNews
//
//  Created by MehulS on 01/10/16.
//  Copyright © 2016 MehulS. All rights reserved.
//


//Reference for XML Parsing : http://www.theappguruz.com/blog/xml-parsing-using-nsxmlparse-swift#sthash.oz7A1vmz.dpuf

import UIKit

//New URL
let URL_NEWS = "https://developer.apple.com/news/rss/news.rss"

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, XMLParserDelegate {

    @IBOutlet weak var tableViewNews: UITableView!
    
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
        // Do any additional setup after loading the view, typically from a nib.
        
        //Set navigation title
        self.title = "Apple Developer News"
        
        //Call method to start parsing news feeds
        self.parseNewsFeeds()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        let imageView = cell?.viewWithTag(101) as! UIImageView
        let lblTitle = cell?.viewWithTag(102) as! UILabel
        
        let dicNews = arrayNews.object(at: indexPath.row) as! NSDictionary
        
        //Set placeholder image
        imageView.image = UIImage(named: "News")
        
        lblTitle.text = dicNews.value(forKey: "title") as? String
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Open link to SAFARI
        let strLink = (arrayNews.object(at: indexPath.row) as! NSDictionary).value(forKey: "link")
        
        UIApplication.shared.openURL(URL(string: strLink as! String)!)
    }
}

