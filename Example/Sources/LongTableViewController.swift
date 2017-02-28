//
//  LongTableViewController.swift
//  Example
//
//  Created by Sean Berry on 2/27/17.
//  Copyright © 2017 Hexed Bits. All rights reserved.
//

import UIKit
import JSQDataSourcesKit

final class LongTableViewController: UITableViewController {
    
    typealias TableCellFactory = ViewFactory<String, UITableViewCell>
    var dataSourceProvider: DataSourceProvider<AlphabatizedStrings, TableCellFactory, TableCellFactory>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 2. create cell factory
        let factory = ViewFactory(reuseIdentifier: CellId) { (cell, model: String?, type, tableView, indexPath) -> UITableViewCell in
            cell.textLabel?.text = model!
            cell.detailTextLabel?.text = "\(indexPath.section), \(indexPath.row)"
            cell.accessibilityIdentifier = "\(indexPath.section), \(indexPath.row)"
            return cell
        }
        
        // 3. create data source provider
        dataSourceProvider = DataSourceProvider(dataSource: AlphabatizedStrings.makeHugeList(), cellFactory: factory, supplementaryFactory: factory)
        
        // 4. set data source
        tableView.dataSource = dataSourceProvider?.tableViewDataSource
    }
}

struct AlphabatizedStrings: DataSourceProtocol, TableSectionIndexing {
    
    let collation = UILocalizedIndexedCollation.current()
    var sections: [[String]] = []
    var strings: [String]
    var convertedSection: [Int:Int] = [:]
    var sectionToContent: [Int:Int] = [:]
    var totalSections = 0
    
    init(strings: [String]) {
        self.strings = strings
        
        let selector: Selector = #selector(getter: NSObjectProtocol.description)
        sections = Array(repeating: [], count: collation.sectionTitles.count)
        
        let sortedObjects = collation.sortedArray(from: strings, collationStringSelector: selector)
        for object in sortedObjects {
            let sectionNumber = collation.section(for: object, collationStringSelector: selector)
            sections[sectionNumber].append(object as! String)
        }
        
        var currentIndex = -1
        for (index, section) in sections.enumerated() {
            if section.count > 0 {
                currentIndex += 1
                sectionToContent[currentIndex] = index
            }
            convertedSection[index] = max(currentIndex, 0)
            
        }
        totalSections = currentIndex + 1
    }
    
    static func makeHugeList() -> AlphabatizedStrings {
        var strings: [String] = []
        for letter in "ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters {
            if arc4random() % 3 == 0 {
                continue
            }
            for num in 1...5 {
                strings.append("\(letter)\(num)")
            }
            
        }
        return AlphabatizedStrings(strings: strings)
    }
    
    func sectionArrayForSection(section: Int) -> [String] {
        return sections[sectionToContent[section]!]
    }
    
    func numberOfSections() -> Int {
        return totalSections
    }
    
    func numberOfItems(inSection section: Int) -> Int {
        return sectionArrayForSection(section: section).count
    }
    
    func items(inSection section: Int) -> [String]? {
        return sectionArrayForSection(section: section)
    }
    
    func item(atRow row: Int, inSection section: Int) -> String? {
        return sectionArrayForSection(section: section)[row]
    }
    
    func headerTitle(inSection section: Int) -> String? {
        return collation.sectionTitles[sectionToContent[section]!]
    }
    
    func footerTitle(inSection section: Int) -> String? {
        return nil
    }
    
    func sectionIndexTitles() -> [String] {
        return collation.sectionIndexTitles
    }
    
    func section(forSectionIndexTitle title: String, at index: Int) -> Int {
        return convertedSection[collation.section(forSectionIndexTitle: index)]!
    }
}
