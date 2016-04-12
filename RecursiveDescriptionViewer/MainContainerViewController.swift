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

extension Desc {
    var pathComponentCells: [NSPathComponentCell] {
        return path
            .componentsSeparatedByString("/")
            .filter{ !$0.isEmpty }
            .map { return NSPathComponentCell(textCell: $0) }
    }
}

class MainContainerViewController: NSViewController, DocumentBased {

    @IBOutlet weak var pathControl: NSPathControl?

    weak var document: Document? {
        didSet {
            document?.selection.afterChange.add { change in
                guard let cells = change.newValue?.pathComponentCells else {
                    return
                }
                self.pathControl?.setPathComponentCells(cells)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let cells = document?.selection.value?.pathComponentCells
            ?? [NSPathComponentCell]()
        self.pathControl?.setPathComponentCells(cells)
    }
}
