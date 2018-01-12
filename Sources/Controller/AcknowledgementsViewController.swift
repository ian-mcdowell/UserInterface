//
//  AcknowledgementsViewController.swift
//  UserInterface
//
//  Created by Ian McDowell on 7/19/17.
//  Copyright © 2017 Ian McDowell. All rights reserved.
//
import UIKit

fileprivate struct Acknowledgement {
    
    // MARK: Properties
    
    let title: String
    let text: String
    
    // MARK: Initialization
    
    /// Initializes a new Acknowledgement instance with the given title and text
    private init(title: String, text: String) {
        self.title = title
        self.text = text
    }
    
    static func acknowledgements(at url: URL) -> [Acknowledgement] {
        var acknowledgements = [Acknowledgement]()
        
        if let plist = NSDictionary(contentsOf: url) as? [String: String] {
            for (key, value) in plist {
                acknowledgements.append(Acknowledgement(title: key, text: value))
            }
        }
        
        return acknowledgements.sorted(by: { $0.title < $1.title })
    }
}

public class AcknowledgementsViewController: SOViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let acknowledgements: [Acknowledgement]
    
    private let tableView = UITableView()
    
    public init(forShowingAcknowledgementsAt url: URL) {
        self.acknowledgements = Acknowledgement.acknowledgements(at: url)
        super.init(nibName: nil, bundle: nil)
        
        self.title = "Acknowledgements"
    }
    
    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SOTableViewCell.self)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 400
        tableView.tableFooterView = UIView()
        
        view.addSubview(tableView)
        tableView.constrainToEdgesOfSuperview()
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return acknowledgements.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(SOTableViewCell.self, for: indexPath)
        
        cell.textLabel?.text = acknowledgements[indexPath.section].text
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight.regular)
        cell.selectionStyle = .none
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return acknowledgements[section].title
    }
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.backgroundView?.backgroundColor = Theme.current?.tableCellBackgroundSelectedColor
        }
    }
}
