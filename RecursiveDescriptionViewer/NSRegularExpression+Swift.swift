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

extension NSRegularExpression {
    func match(string: String) -> String? {
        let nsString = (string as NSString)
        let opts = NSMatchingOptions.WithTransparentBounds
        let range = NSMakeRange(0, nsString.length)
        guard let match = self.firstMatchInString(string, options: opts, range: range) else {
            return nil
        }
        guard match.numberOfRanges <= 2 else {
            print("Too Many Capture Groups: \(match.numberOfRanges)")
            return nil
        }
        let matchIndex = match.numberOfRanges - 1
        let resultRange = match.rangeAtIndex(matchIndex)
        let result = nsString.substringWithRange(resultRange)
        return result
    }
}