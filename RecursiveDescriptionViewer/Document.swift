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
import Observable

protocol DocumentBased {
    weak var document: Document? { get set }
}

extension NSViewController {
    func didLoadDocument(document: Document) {
        if var vc = self as? DocumentBased {
            vc.document = document
        }
        childViewControllers.forEach { cvc in
            cvc.didLoadDocument(document)
        }
    }
}

final class Document: NSDocument {
    private let windowID = "Document Window Controller"
    private(set) var model: Desc?
    private(set) var selection: Observable<Desc?> = Observable(nil)

    override class func autosavesInPlace() -> Bool {
        return false
    }

    override func makeWindowControllers() {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let windowController = storyboard.instantiateControllerWithIdentifier(windowID) as! NSWindowController
        self.addWindowController(windowController)
    }

    override func readFromData(data: NSData, ofType typeName: String) throws {
        guard let modelString = String(data: data, encoding: NSUTF8StringEncoding) else {
            Swift.print("Failed to read file data")
            return
        }
        var parser = try Parser(string: modelString)
        model = try parser.parse()
        model?.processScrollviewContent()
    }

    func select(model: Desc?) {
        selection.value = model
    }

    func selectSuper() {
        selection.value = selection.value?.superview
    }

    func selectNext() {
        guard
            let selectedModel = selection.value,
            let models = selectedModel.superview?.subviews,
            let selectedIndex = models.indexOf(selectedModel),
            let proposedSelection = models[safe: selectedIndex + 1]
            else { return }

        selection.value = proposedSelection
    }

    func selectPrev() {
        guard
            let selectedModel = selection.value,
            let models = selectedModel.superview?.subviews,
            let selectedIndex = models.indexOf(selectedModel),
            let proposedSelection = models[safe: selectedIndex - 1]
            else { return }

        selection.value = proposedSelection
    }
}

