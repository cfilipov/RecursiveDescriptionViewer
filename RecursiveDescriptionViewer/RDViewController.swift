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

final class RDViewController: NSViewController, DocumentBased {

    @IBOutlet weak var box: NSBox!
    @IBOutlet weak var contentView: NSView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!

    var viewMap = [Desc : RDView]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    weak var document: Document? {
        didSet {
            guard let doc = document, let model = doc.model else {
                return
            }
            if let frame = model.elem.frame {
                widthConstraint.constant = frame.size.width
                heightConstraint.constant = frame.size.height
                let root = FlippedView(frame: frame)
                addSubviews(fromModel: model, toView: root)
                contentView.addSubview(root)
            }
            doc.selection.afterChange.add { change in
                if let oldValue = change.oldValue {
                    let view = self.viewMap[oldValue]
                    view?.highlighted = false
                }
                if let newValue = change.newValue {
                    let view = self.viewMap[newValue]
                    view?.highlighted = true
                }
            }
        }
    }

    func addSubviews(fromModel model: Desc, toView view: NSView) {
        model.dfs { m in
            var cur = m
            var frame = m.elem.frame ?? CGRectZero
            while cur.superview != nil {
                guard
                    let sup = cur.superview,
                    let supFrame = sup.elem.frame
                    else {
                        return .Stop
                }
                frame = frame.offsetBy(
                    dx: supFrame.origin.x,
                    dy: supFrame.origin.y
                )
                cur = sup
            }
            let modelView = RDView(frame: frame, model: m)
            modelView.onMouseDown = { v in
                if let m = v.model {
                    self.document?.select(m)
                }
            }
            view.addSubview(modelView)
            self.viewMap[m] = modelView
            return .Continue
        }
    }

}

