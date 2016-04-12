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

final class InspectorViewController: NSViewController, DocumentBased {

    @IBOutlet weak var stackView: TSStackView?
    @IBOutlet weak var frameXField: NSTextField?
    @IBOutlet weak var frameYField: NSTextField?
    @IBOutlet weak var frameWidthField: NSTextField?
    @IBOutlet weak var frameHeightField: NSTextField?
    @IBOutlet weak var nameField: NSTextField?
    @IBOutlet weak var addressField: NSTextField?
    @IBOutlet weak var superviewNameField: NSTextField?
    @IBOutlet weak var superviewAddressField: NSTextField?
    @IBOutlet weak var goToSuperButton: NSButton?

    weak var document: Document? {
        didSet {
            document?.selection.afterChange.add { change in
                self.populateSubviews()
                self.updateFields()
            }
        }
    }

    @IBAction func onGoToSuperButtonPressed(sender: NSButton?) {
        document?.selectSuper()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        stackView?.autoContentSizeOptions = TSAutoContentSize.Height
        self.populateSubviews()
        self.updateFields()
    }

    func subviewButtonPressed(button: NSButton?) {
        guard let index = button?.tag else {
            return
        }
        guard let proposedSelection = document?.selection.value?.subviews[index] else {
            return
        }
        document?.select(proposedSelection)
    }

    func populateSubviews() {
        guard let selectedModel = document?.selection.value else {
            return
        }
        var views = [NSButton]()
        selectedModel.subviews.forEach { m in
            let button = NSButton(frame: CGRect(x: 0, y: 0, width: 180, height: 17))
            button.title = "\(m.elem.name)"
            button.setButtonType(.MomentaryPushInButton)
            button.bezelStyle = .InlineBezelStyle
            button.lineBreakMode = .ByTruncatingTail
            button.target = self
            button.action = "subviewButtonPressed:"
            button.tag = selectedModel.subviews.indexOf(m)!
            views.append(button)
        }
        stackView?.setViews(views, inGravity: .Top)
    }

    func updateFields() {
        let selected = document?.selection.value
        nameField?.stringValue = selected?.elem.name ?? ""
        addressField?.stringValue = selected?.elem.address ?? ""

        if let frame = selected?.elem.frame {
            frameXField?.stringValue = "\(frame.origin.x)"
            frameYField?.stringValue = "\(frame.origin.y)"
            frameWidthField?.stringValue = "\(frame.size.width)"
            frameHeightField?.stringValue = "\(frame.size.height)"
        }

        let sup = document?.selection.value?.superview
        superviewNameField?.stringValue = sup?.elem.name ?? ""
        superviewAddressField?.stringValue = sup?.elem.address ?? ""

        goToSuperButton?.enabled = sup != nil
    }
}
