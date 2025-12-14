//
// SaveFileValidator.swift
// Sentinel Worlds I: Future Magic Save Game Editor
//
// Copyright (C) 2025 Lee Hutchinson (lee@bigdinosaur.org)
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.
//

import Foundation

/// Validates Sentinel Worlds save files before loading
struct SaveFileValidator {

    // MARK: - Constants

    private static let sentinelSignatureAddress = 0x3181
    private static let sentinelSignature = Data("Sentinel".utf8)
    private static let maxSaveFileSize = 16384  // 16KB - save files are ~12KB
    private static let minSaveFileSize = 1024   // 1KB minimum

    // MARK: - Validation Errors

    enum ValidationError: LocalizedError {
        case fileNotFound(path: String)
        case notAFile(path: String)
        case fileNotReadable(path: String)
        case fileTooLarge(size: Int)
        case fileTooSmall(size: Int)
        case invalidFilename(name: String)
        case invalidSignature
        case directoryNotWritable(path: String)
        case ioError(description: String)

        var errorDescription: String? {
            switch self {
            case .fileNotFound(let path):
                return "File not found: \(path)"
            case .notAFile(let path):
                return "Path is not a file: \(path)"
            case .fileNotReadable(let path):
                return "File is not readable: \(path)"
            case .fileTooLarge(let size):
                return "File is too large (\(size) bytes). Expected ~12KB, max 16KB."
            case .fileTooSmall(let size):
                return "File is too small (\(size) bytes). Likely not a valid save file."
            case .invalidFilename(let name):
                return "Filename must match pattern 'gameX.fm' where X is A-Z (found: \(name))"
            case .invalidSignature:
                return "File does not appear to be a valid Sentinel Worlds save file (signature mismatch)"
            case .directoryNotWritable(let path):
                return "Directory is not writable: \(path)\nCannot save changes or create backup files."
            case .ioError(let description):
                return "Error reading file: \(description)"
            }
        }
    }

    // MARK: - Validation Method

    /// Validates that a file is a legitimate Sentinel Worlds save file
    ///
    /// Checks performed:
    /// - File exists
    /// - File is readable
    /// - File size is reasonable (1KB-16KB)
    /// - File has "Sentinel" signature at 0x3181
    /// - Filename matches pattern gameX.fm (X = A-Z, case-insensitive)
    /// - File location is writable (for saving and backup) - optional
    ///
    /// - Parameters:
    ///   - url: URL of the file to validate
    ///   - requireWritable: Whether to require the directory to be writable (default: false for read-only access)
    /// - Throws: ValidationError if any check fails
    static func validate(url: URL, requireWritable: Bool = false) throws {
        let fileManager = FileManager.default
        let path = url.path

        // Check file exists
        guard fileManager.fileExists(atPath: path) else {
            throw ValidationError.fileNotFound(path: path)
        }

        // Check it's actually a file (not a directory)
        var isDirectory: ObjCBool = false
        fileManager.fileExists(atPath: path, isDirectory: &isDirectory)
        guard !isDirectory.boolValue else {
            throw ValidationError.notAFile(path: path)
        }

        // Check file is readable
        guard fileManager.isReadableFile(atPath: path) else {
            throw ValidationError.fileNotReadable(path: path)
        }

        // Check file size
        let attributes: [FileAttributeKey: Any]
        do {
            attributes = try fileManager.attributesOfItem(atPath: path)
        } catch {
            throw ValidationError.ioError(description: error.localizedDescription)
        }

        guard let fileSize = attributes[.size] as? Int else {
            throw ValidationError.ioError(description: "Could not determine file size")
        }

        if fileSize > maxSaveFileSize {
            throw ValidationError.fileTooLarge(size: fileSize)
        }

        if fileSize < minSaveFileSize {
            throw ValidationError.fileTooSmall(size: fileSize)
        }

        // Check filename matches pattern gameX.fm (X = A-Z, case-insensitive)
        let filename = url.lastPathComponent.lowercased()
        let pattern = "^game[a-z]\\.fm$"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(filename.startIndex..<filename.endIndex, in: filename)

        guard regex?.firstMatch(in: filename, range: range) != nil else {
            throw ValidationError.invalidFilename(name: url.lastPathComponent)
        }

        // Check file has correct signature at 0x3181
        do {
            let fileHandle = try FileHandle(forReadingFrom: url)
            defer { try? fileHandle.close() }

            try fileHandle.seek(toOffset: UInt64(sentinelSignatureAddress))
            let signatureData = fileHandle.readData(ofLength: sentinelSignature.count)

            guard signatureData == sentinelSignature else {
                throw ValidationError.invalidSignature
            }
        } catch let error as ValidationError {
            throw error
        } catch {
            throw ValidationError.ioError(description: error.localizedDescription)
        }

        // Check directory is writable (needed for saving changes and creating backups)
        // This check is optional for read-only access
        if requireWritable {
            let directory = url.deletingLastPathComponent().path
            guard fileManager.isWritableFile(atPath: directory) else {
                throw ValidationError.directoryNotWritable(path: directory)
            }
        }
    }
}
