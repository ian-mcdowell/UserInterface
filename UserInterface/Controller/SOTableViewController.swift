//
//  SOTableViewController.swift
//  UserInterface
//
//  Created by Ian McDowell on 7/18/17.
//  Copyright © 2017 Ian McDowell. All rights reserved.
//

open class SOTableViewController: SOViewController, UITableViewDataSource, UITableViewDelegate {
    
    public let tableView: UITableView
    public var refreshControl: UIRefreshControl? {
        didSet {
            oldValue?.removeFromSuperview()
            if let refreshControl = refreshControl {
                tableView.addSubview(refreshControl)
            }
        }
    }
    
    public init(style: UITableViewStyle) {
        self.tableView = UITableView(frame: .zero, style: style)
        super.init(nibName: nil, bundle: nil)
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    open override func loadView() {
        self.view = tableView
    }
    
    open override func applyTheme(_ theme: Theme) {
        super.applyTheme(theme)
        
        tableView.reloadData()
    }
    
    // MARK: UITableViewDataSource
    
    dynamic open func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    
    dynamic open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    dynamic open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("Please override tableView(cellForRowAt:) in your SOTableViewController subclass.")
    }
    
    // MARK: UITableViewDelegate
    
}
