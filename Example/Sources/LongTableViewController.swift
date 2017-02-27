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
    
    init(strings: [String]) {
        self.strings = strings
        
        let selector: Selector = #selector(getter: NSObjectProtocol.description)
        sections = Array(repeating: [], count: collation.sectionTitles.count)
        
        let sortedObjects = collation.sortedArray(from: strings, collationStringSelector: selector)
        for object in sortedObjects {
            let sectionNumber = collation.section(for: object, collationStringSelector: selector)
            sections[sectionNumber].append(object as! String)
        }
    }
    
    static func makeHugeList() -> AlphabatizedStrings {
        var strings: [String] = []
        for letter in "ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters {
            for num in 1...5 {
                strings.append("\(letter)\(num)")
            }
        }
        return AlphabatizedStrings(strings: strings)
    }
    
    func numberOfSections() -> Int {
        return sections.count
    }
    
    func numberOfItems(inSection section: Int) -> Int {
        return sections[section].count
    }
    
    func items(inSection section: Int) -> [String]? {
        return sections[section]
    }
    
    func item(atRow row: Int, inSection section: Int) -> String? {
        return sections[section][row]
    }
    
    func headerTitle(inSection section: Int) -> String? {
        return collation.sectionTitles[section]
    }
    
    func footerTitle(inSection section: Int) -> String? {
        return nil
    }
    
    func sectionIndexTitles() -> [String] {
        return collation.sectionIndexTitles
    }
    
    func section(forSectionIndexTitle title: String, at index: Int) -> Int {
        return collation.section(forSectionIndexTitle: index)
    }
}
