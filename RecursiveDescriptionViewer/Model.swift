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

import Foundation

final class Desc {
    var elem: Elem
    var subviews: [Desc]
    var superview: Desc?

    init(elem: Elem, subviews: [Desc] = []) {
        self.elem = elem
        self.subviews = subviews
        subviews.forEach { subview in
            subview.superview = self
        }
    }
}

final class Elem {
    let string: String
    var name: String
    var address: String
    var props: [Prop]

    init(string: String, name: String, address: String, props: [Prop] = []) {
        self.string = string
        self.name = name
        self.address = address
        self.props = props
    }
}

enum Prop {
    case Frame(CGRect)
    case ContentSize(CGSize)
    case ContentOffset(CGPoint)
    case KeyValue(String, Value)
}

enum Value {
    case StringValue(String)
    case ElemValue(Elem)
}

// MARK: Extensions

extension Desc {
    var path: String {
        return (superview?.path ?? "/") + "\(elem.name)/"
    }
}

extension Desc: Hashable {
    var hashValue: Int {
        return (elem.address + elem.name).hashValue
    }
}

extension Desc: GraphTraversable {
    var nodes: [Desc] {
        return subviews
    }
}

func ==(lhs: Desc, rhs: Desc) -> Bool {
    return lhs.elem.address == rhs.elem.address
}

extension Elem {
    var frame: CGRect? {
        get {
            for prop in props {
                switch prop {
                case .Frame(let rect): return rect
                default: continue
                }
            }
            return nil
        }
        set(newVal) {
            if let v = newVal {
                props = props.map { p in
                    switch p {
                    case .Frame(_):
                        return Prop.Frame(v)
                    default: return p
                    }
                }
            }
            else {
                props = props.filter { p in
                    switch p {
                    case .Frame(_):
                        return false
                    default: return true
                    }
                }
            }
        }
    }
    var contentOffset: CGPoint? {
        for prop in props {
            switch prop {
            case .ContentOffset(let point): return point
            default: continue
            }
        }
        return nil
    }
    var contentSize: CGSize? {
        for prop in props {
            switch prop {
            case .ContentSize(let size): return size
            default: continue
            }
        }
        return nil
    }
}

extension Desc {
    /**
    Insert models representing the ScrollView content area.

    Children of UIScrollView instances (and their subclasses like tableView) have frames whose origins are relative to the contentOffset of the scrollview. Laying out these views will result in the views being placed incorrectly.
    */
    func processScrollviewContent() {
        dfs { node in
            if let size = node.elem.contentSize,
                let offset = node.elem.contentOffset
                where size.width != 0 && size.height != 0 {
                    let containerFrame = CGRect(
                        origin: CGPoint(
                            x: -offset.x,
                            y: -offset.y
                        ),
                        size: size
                    )
                    let containerElem = Elem(
                        string: "Scroll View Content",
                        name: "Scroll View Content",
                        address: node.elem.address,
                        props: [Prop.Frame(containerFrame)]
                    )
                    let model = Desc(
                        elem: containerElem,
                        subviews: node.subviews
                    )
                    model.superview = node
                    node.subviews = [model]
            }
            return .Continue
        }
    }
}