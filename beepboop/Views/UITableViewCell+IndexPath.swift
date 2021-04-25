//
//  UITableViewCell+IndexPath.swift
//  beepboop
//
//  Created by Amy Ouyang on 4/25/21.
//

import UIKit

extension UIResponder {
    /**
     * Returns the next responder in the responder chain cast to the given type, or
     * if nil, recurses the chain until the next responder is nil or castable.
     */
    func next<U: UIResponder>(of type: U.Type = U.self) -> U? {
        return self.next.flatMap({ $0 as? U ?? $0.next() })
    }
}

extension UITableViewCell {
    var tableView: UITableView? {
        print("self.next of table view: ", self.next(of: UITableView.self))
        return self.next(of: UITableView.self)
    }

    var indexPath: IndexPath? {
        print("indexpath: ", self.tableView?.indexPath(for: self))
        return self.tableView?.indexPath(for: self)
    }
    
}


