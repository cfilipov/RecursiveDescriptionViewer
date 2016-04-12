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

let DummyMatch = "<DummyMatch>"

struct IndentGenerator: GeneratorType {
    var tokenizer: ViewHierarchyTokenizer
    var depthStack = Stack<Int>()
    var curDepth = 0

    init(tokenizer: ViewHierarchyTokenizer) throws {
        self.tokenizer = tokenizer
        depthStack.push(0)
    }

    mutating func next() -> TokenMatch? {
        if depthStack.top() > curDepth {
            depthStack.pop()
            return TokenMatch(token: .DEDENT, match: DummyMatch)
        }
        guard let tokenMatch = tokenizer.next() else {
            if depthStack.top() != 0 {
                curDepth = 0
                depthStack.pop()
                return TokenMatch(token: .DEDENT, match: DummyMatch)
            }
            else {
                return nil
            }
        }
        if tokenMatch.token == .DEPTH {
            curDepth = tokenMatch.match.componentsSeparatedByString("|").count - 1
            if curDepth > depthStack.top() {
                depthStack.push(curDepth)
                return TokenMatch(token: .INDENT, match: tokenMatch.match)
            }
            else {
                return next()
            }
        }
        assert(tokenMatch.token != .DEPTH)
        return tokenMatch
    }
}