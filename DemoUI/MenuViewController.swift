//
//  MenuViewController.swift
//  DemoUI
//
//  Created by wizard lee on 7/26/16.
//  Copyright © 2016 wizard lee. All rights reserved.
//

import UIKit

class MenuViewController: UITableViewController {
    let segues = ["CoordinateHeader",
                  "AutoLayout"]

}

extension MenuViewController {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return segues.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath)
        cell.textLabel?.text = segues[indexPath.item]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(segues[indexPath.item], sender: self)
    }
}
