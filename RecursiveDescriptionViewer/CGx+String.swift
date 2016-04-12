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

extension CGFloat {
    init?(fromString string: String) {
        guard let n = NSNumberFormatter().numberFromString(string) else {
            return nil
        }
        self.init(n)
    }
}

extension CGPoint {
    init?(fromString string: String) {
        let components = string
            .stringByReplacingOccurrencesOfString(",", withString: "")
            .componentsSeparatedByString(" ")
        let x = CGFloat(fromString: components[0])!
        let y = CGFloat(fromString: components[1])!
        self.init(x: x, y: y)
    }
}

extension CGSize {
    init?(fromString string: String) {
        let components = string
            .stringByReplacingOccurrencesOfString(",", withString: "")
            .componentsSeparatedByString(" ")
        let width = CGFloat(fromString: components[0])!
        let height = CGFloat(fromString: components[1])!
        self.init(width: width, height: height)
    }
}

extension CGRect {
    init?(fromString string: String) {
        let components = string
            .stringByReplacingOccurrencesOfString(";", withString: "")
            .componentsSeparatedByString(" ")
        let x = CGFloat(fromString: components[0])!
        let y = CGFloat(fromString: components[1])!
        let width = CGFloat(fromString: components[2])!
        let height = CGFloat(fromString: components[3])!
        self.init(x: x, y: y, width: width, height: height)
    }
    func adjust(forParents parents: [CGRect]) -> CGRect {
        var parent = CGRectZero
        parents.forEach { item in
            parent = parent.offsetBy(dx: item.origin.x, dy: item.origin.y)
        }
        return self.offsetBy(dx: parent.origin.x, dy: parent.origin.y)
    }
}
