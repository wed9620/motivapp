////////////////////////////////////////////////////////////////////////////
//
// Copyright 2014 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

import Realm


/**
Enumeration that describes the error codes within the Realm error domain.
The values can be used to catch a variety of _recoverable_ errors, especially those
happening when initializing a Realm instance.

    let realm: Realm?
    do {
        realm = Realm()
    } catch RealmSwift.Error.IncompatibleLockFile() {
        print("Realm Browser app may be attached to Realm on device?")
    }

*/
public enum Error: Error {
    // swiftlint:disable variable_name
    /// :nodoc:
    public var _code: Int {
        return rlmError.rawValue
    }

    /// :nodoc:
    public var _domain: String {
        return RLMErrorDomain
    }
    // swiftlint:enable variable_name

    /// The RLMError value, which can be used to derive the error's code.
    fileprivate var rlmError: RLMError {
        switch self {
        case .fail:
            return RLMError.fail
        case .fileAccess:
            return RLMError.fileAccess
        case .filePermissionDenied:
            return RLMError.filePermissionDenied
        case .fileExists:
            return RLMError.fileExists
        case .fileNotFound:
            return RLMError.fileNotFound
        case .incompatibleLockFile:
            return RLMError.incompatibleLockFile
        case .fileFormatUpgradeRequired:
            return RLMError.fileFormatUpgradeRequired
        }
    }

    /// Error thrown by Realm if no other specific error is returned when a realm is opened.
    case fail

    /// Error thrown by Realm for any I/O related exception scenarios when a realm is opened.
    case fileAccess

    /// Error thrown by Realm if the user does not have permission to open or create
    /// the specified file in the specified access mode when the realm is opened.
    case filePermissionDenied

    /// Error thrown by Realm if the file already exists when a copy should be written.
    case fileExists

    /// Error thrown by Realm if no file was found when a realm was opened as
    /// read-only or if the directory part of the specified path was not found
    /// when a copy should be written.
    case fileNotFound

    /// Error thrown by Realm if the database file is currently open in another process which
    /// cannot share with the current process due to an architecture mismatch.
    case incompatibleLockFile

    /// Returned by RLMRealm if a file format upgrade is required to open the file,
    /// but upgrades were explicilty disabled.
    case fileFormatUpgradeRequired
}

// MARK: Equatable

extension Error: Equatable {}

/// Returns whether the two errors are identical
public func == (lhs: Error, rhs: Error) -> Bool { // swiftlint:disable:this valid_docs
    return lhs._code == rhs._code
        && lhs._domain == rhs._domain
}

// MARK: Pattern Matching

/**
Explicitly implement pattern matching for `Realm.Error`, so that the instances can be used in the
`do … syntax`.
*/
public func ~= (lhs: Error, rhs: Error) -> Bool { // swiftlint:disable:this valid_docs
    return lhs == rhs
}
