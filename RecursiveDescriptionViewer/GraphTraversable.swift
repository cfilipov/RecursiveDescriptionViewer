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

protocol GraphTraversable {
    typealias GraphType : Hashable
    var nodes: [GraphType] { get }
}

enum Status {
    case Continue
    case Stop
}

extension GraphTraversable where GraphType == Self {
    func dfs(callback: GraphType -> Status) {
        var stack = [GraphType]()
        stack.append(self)
        var visited = Set<GraphType>()
        var status = Status.Continue
        while !stack.isEmpty && status == .Continue {
            let n = stack.removeLast()
            status = callback(n)
            visited.insert(n)
            n.nodes.forEach { sub in
                if !visited.contains(sub) {
                    stack.append(sub)
                }
            }
        }
    }
}