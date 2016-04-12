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

final class RDView: FlippedView {
    private let normalBorderColor = NSColor.lightGrayColor().CGColor
    private let normalBackgroundColor = NSColor(red: 1, green: 1, blue: 1, alpha: 0.05).CGColor
    private let highlightedBorderColor = NSColor.blueColor().CGColor
    private let highlightedBackgroundColor = NSColor(red: 0, green: 0, blue: 1, alpha: 0.15).CGColor

    var model: Desc?
    var onMouseDown: (RDView) -> () = { _ in }

    convenience init(frame: CGRect, model: Desc) {
        self.init(frame: frame)
        self.model = model
        toolTip = "\(model.elem.string)"
    }

    required override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        wantsLayer = true
        if let layer = layer {
            layer.borderColor = normalBorderColor
            layer.backgroundColor = normalBackgroundColor
            layer.borderWidth = 1
            layer.masksToBounds = false
        }
    }

    override var flipped: Bool {
        return true
    }

    override var wantsDefaultClipping: Bool {
        return false
    }

    var borderColor: NSColor? {
        get {
            if let color = layer?.borderColor {
                return NSColor(CGColor: color)
            }
            else {
                return nil
            }
        }
        set(color) {
            if let color = color {
                layer?.borderColor = color.CGColor
            }
        }
    }

    var highlighted = false {
        didSet {
            if self.highlighted == true {
                self.layer?.borderColor = highlightedBorderColor
                self.layer?.backgroundColor = highlightedBackgroundColor
            }
            else {
                self.layer?.borderColor = normalBorderColor
                self.layer?.backgroundColor = normalBackgroundColor
            }
        }
    }

    override func mouseDown(theEvent: NSEvent) {
        onMouseDown(self)
    }
}

