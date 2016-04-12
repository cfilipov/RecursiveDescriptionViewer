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

struct Parser {
    enum Error: ErrorType {
        case UnexpectedToken(TokenMatch)
    }

    var tokens: IndentGenerator
    var curMatch: TokenMatch?
    var nextMatch: TokenMatch?

    let namePattern: NSRegularExpression
    let addressPattern: NSRegularExpression
    let framePattern: NSRegularExpression
    let contentSizePattern: NSRegularExpression
    let contentOffsetPattern: NSRegularExpression

    init(string: String) throws {
        namePattern = try "<([a-z0-9_]*): 0x[a-f0-9]*".regex()
        addressPattern = try "<[a-z0-9_]*: (0x[a-f0-9]*)".regex()
        framePattern = try "frame = \\(([^\\)]*)\\)".regex()
        contentSizePattern = try "contentSize: \\{([^\\}]*)\\}".regex()
        contentOffsetPattern = try "contentOffset: \\{([^\\}]*)\\}".regex()

        curMatch = nil
        nextMatch = nil
        let tokenizer = try ViewHierarchyTokenizer(string: string)
        tokens = try IndentGenerator(tokenizer: tokenizer)
        consume()
    }

    mutating func parse() throws -> Desc {
        return try parseDesc()
    }

    func peek() -> TokenMatch? {
        return nextMatch
    }

    mutating func consume() -> TokenMatch? {
        curMatch = nextMatch
        nextMatch = tokens.next()
        if let next = nextMatch {
            assert(next.token != .DEPTH)
        }
        return curMatch
    }

    mutating func accept(tok: Token) -> Bool {
        if let next = peek() where tok == next.token {
            consume()
            return true
        }
        return false
    }

    mutating func expect(tok: Token) throws -> Bool {
        if accept(tok) {
            return true
        }
        throw Error.UnexpectedToken(peek()!)
    }

    /*
    * desc = elem [INDENT desc+ DEDENT]
    */
    mutating func parseDesc() throws -> Desc {
        let elem = try parseElem()
        var subviews = [Desc]()
        if accept(.INDENT) {
            while peek()?.token == .ELEM {
                let subview = try parseDesc()
                subviews.append(subview)
            }
            try expect(.DEDENT)
        }
        return Desc(elem: elem, subviews:subviews)
    }



    mutating func parseElem() throws -> Elem {
        try expect(.ELEM)
        guard let c = curMatch else {
            throw Error.UnexpectedToken(peek()!)
        }
        let string = c.match
        guard
            let name = namePattern.match(string),
            let address = addressPattern.match(string) else {
                throw Error.UnexpectedToken(peek()!)
        }
        let props = try parseElemProps()
        let elem = Elem(string: c.match, name: name, address: address, props: props)
        return elem
    }

    mutating func parseElemProps() throws -> [Prop] {
        guard let c = curMatch else {
            throw Error.UnexpectedToken(peek()!)
        }
        let string = c.match
        var props = [Prop]()
        if let frameStr = framePattern.match(string) {
            if let frame = CGRect(fromString: frameStr) {
                let prop = Prop.Frame(frame)
                props.append(prop)
            }
        }
        if let contentSizeStr = contentSizePattern.match(string) {
            if let size = CGSize(fromString: contentSizeStr) {
                let prop = Prop.ContentSize(size)
                props.append(prop)
            }
        }
        if let contentSizeStr = contentOffsetPattern.match(string) {
            if let offset = CGPoint(fromString: contentSizeStr) {
                let prop = Prop.ContentOffset(offset)
                props.append(prop)
            }
        }
        return props
    }

}
