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

final class OutlineViewController: NSViewController, NSOutlineViewDataSource, DocumentBased, NSOutlineViewDelegate {
    
    @IBOutlet weak var outlineView: NSOutlineView!

    var model: Desc?

    weak var document: Document? {
        didSet {
            model = document?.model
            outlineView.reloadData()
            document?.selection.afterChange.add { change in
                let indexes = NSMutableIndexSet()
                let row = self.outlineView.rowForItem(change.newValue)
                indexes.addIndex(row)
                assert(row != -1)
                self.outlineView.selectRowIndexes(
                    indexes,
                    byExtendingSelection: false
                )
                self.outlineView.scrollRowToVisible(indexes.firstIndex)
            }
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        outlineView.expandItem(nil, expandChildren: true)
    }

    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        if let item = item as? Desc {
            return item.subviews.count
        }
        if let _ = model {
            return 1
        }
        return 0
    }

    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        if let item = item as? Desc {
            return item.subviews[index]
        }
        else {
            return model!
        }
    }

    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        if let item = item as? Desc {
            return item.subviews.count > 0
        }
        else {
            return false
        }
    }

    func outlineView(outlineView: NSOutlineView, objectValueForTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) -> AnyObject? {
        if let item = item as? Desc {
            return "\(item.elem.name)"
        }
        else {
            return nil
        }
    }

    func outlineView(outlineView: NSOutlineView, selectionIndexesForProposedSelection proposedSelectionIndexes: NSIndexSet) -> NSIndexSet {
        assert(proposedSelectionIndexes.count <= 1)
        let index = proposedSelectionIndexes.firstIndex
        let item = outlineView.itemAtRow(index)
        if let item = item as? Desc {
            self.document?.select(item)
        }
        return proposedSelectionIndexes
    }
}