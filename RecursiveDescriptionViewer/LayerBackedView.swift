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

@IBDesignable class LayerBackedView : NSView {
    @IBInspectable var backgroundColor: NSColor? {
        get {
            guard let color = layer?.backgroundColor else {
                return nil
            }
            return NSColor(CGColor: color)
        }
        set(color) {
            layer?.backgroundColor = color?.CGColor
        }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initLayer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initLayer()
    }

    func initLayer() {
        wantsLayer = true
    }
}