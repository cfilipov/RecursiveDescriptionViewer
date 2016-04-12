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

enum Token {
    case DEPTH
    case INDENT
    case DEDENT
    case ELEM
}

struct LineContext {
    let line: Int
    let pos: Int
}

struct TokenMatch {
    let token: Token
    let match: String
}

struct ViewHierarchyTokenizer: GeneratorType {
    let scanner: NSScanner
    let depthPattern: NSRegularExpression

    init(string: String) throws {
        depthPattern = try "[ |]+".regex()
        scanner = NSScanner(string: string)
        scanner.charactersToBeSkipped = .whitespaceCharacterSet()
    }

    mutating func next() -> TokenMatch? {
        if scanner.atEnd {
            return nil
        }
        if let depthStr = scanner.scanRegex(depthPattern) {
            return TokenMatch(token: .DEPTH, match: depthStr)
        }
        if let desc = scanner.scanUpToString("\n") {
            scanner.scanString("\n")
            return TokenMatch(token: .ELEM, match: desc)
        }
        return nil
    }

}
