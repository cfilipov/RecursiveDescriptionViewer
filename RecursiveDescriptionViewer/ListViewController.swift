/*
 RecursiveDescriptionViewer
 Copyright (C) 2016  Cristian Filipov
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import Cocoa

class ListViewController: NSViewController, DocumentBased {

    @IBOutlet weak var browser: NSBrowser!

    weak var document: Document? {
        didSet {
            document?.selection.afterChange.add { change in
                if let path = change.newValue?.path {
                    self.browser.setPath(path)
                }
            }
        }
    }
}

extension ListViewController: NSBrowserDelegate {
    func rootItemForBrowser(browser: NSBrowser) -> AnyObject? {
        return document?.model
    }

    func browser(browser: NSBrowser, numberOfChildrenOfItem item: AnyObject?) -> Int {
        return (item as! Desc).subviews.count
    }

    func browser(browser: NSBrowser, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        return (item as! Desc).subviews[index]
    }

    func browser(browser: NSBrowser, isLeafItem item: AnyObject?) -> Bool {
        return (item as! Desc).subviews.isEmpty
    }

    func browser(browser: NSBrowser, objectValueForItem item: AnyObject?) -> AnyObject? {
        let item = item as! Desc
        return "\(item.elem.name): \(item.elem.address)"
    }

    func browser(browser: NSBrowser, selectionIndexesForProposedSelection proposedSelectionIndexes: NSIndexSet, inColumn column: Int) -> NSIndexSet {

        let index = proposedSelectionIndexes.firstIndex
        let item = browser.itemAtRow(index, inColumn: column)
        if let item = item as? Desc {
            document?.select(item)
        }
        return proposedSelectionIndexes
    }
}