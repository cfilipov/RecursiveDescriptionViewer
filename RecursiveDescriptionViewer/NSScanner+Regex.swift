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

extension NSScanner {
    final func peekNext() -> String {
        let range = NSMakeRange(scanLocation, 1)
        return (string as NSString).substringWithRange(range)
    }

    final func removeLeadingWhiteSpace() {
        /*
        HACK:

        Temporarily disable skipped characters so we can trim out the whitespace that would otherwise screw up our regex match.
        */
        while peekNext() == " " {
            scanLocation++
        }
    }

    /**
    Returns the first match for the given regex string starting from the scanLocation until the end of the string.
    
    Important: It's almost certainly better to use scanRegex(regex:) instead unless you plan to only call this once for a particular pattern. This method compiles the regex string before doing the match which can be quite expensive.
    */
    final func scanRegex(string regexString: String) throws -> String? {
        let regexOpts = NSRegularExpressionOptions.CaseInsensitive
        let regex = try NSRegularExpression(pattern: regexString, options: regexOpts)
        return scanRegex(regex)
    }

    /**
    Returns the first match for the given NSRegularExpression starting from the scanLocation until the end of the string.
    */
    final func scanRegex(regex: NSRegularExpression) -> String? {
        let nsString = string as NSString
        removeLeadingWhiteSpace()
        let matchOpts = NSMatchingOptions.Anchored
        let matchRange = NSMakeRange(scanLocation, nsString.length - scanLocation)
        guard let match = regex.firstMatchInString(string, options: matchOpts, range: matchRange) else {
            return nil
        }
        guard match.numberOfRanges <= 2 else {
            print("Too Many Capture Groups: \(match.numberOfRanges)")
            return nil
        }
        let matchIndex = match.numberOfRanges - 1
        let consumedRange = match.rangeAtIndex(0)
        let resultRange = match.rangeAtIndex(matchIndex)
        let result = nsString.substringWithRange(resultRange)
        self.scanLocation += consumedRange.length
        return result
    }
}