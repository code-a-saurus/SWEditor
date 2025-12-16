//
// BinaryFileIO.swift
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

/// Handles low-level binary file I/O for Sentinel Worlds save files
/// Mirrors Python main.py functions: read_bytes, write_bytes, read_string, write_string
///
/// CRITICAL: All multi-byte integers use little-endian byte order to match the
/// original MS-DOS save file format. Bytes [0x3F, 0x42] must read as 0x423F (16959),
/// NOT 0x3F42 (16194).
class BinaryFileIO {

    // MARK: - Reading Operations

    /// Read 1-3 bytes from file at specific address (little-endian byte order)
    ///
    /// This is the core function for reading save game data. The save file format
    /// stores all multi-byte integers in little-endian format (least significant
    /// byte first), which was standard for MS-DOS/x86 systems.
    ///
    /// Example:
    /// ```
    /// // File contains bytes: [0x3F, 0x42, 0x00] at address 0x024C
    /// let cash = try BinaryFileIO.readBytes(from: fileHandle, address: 0x024C, numBytes: 3)
    /// // Result: 0x00423F = 16959 (not 0x3F4200!)
    /// ```
    ///
    /// - Parameters:
    ///   - fileHandle: Open file handle for reading
    ///   - address: Hex address to read from (e.g., 0x024C for party cash)
    ///   - numBytes: Number of bytes to read (1, 2, or 3)
    /// - Returns: Integer value in host byte order
    /// - Throws: BinaryIOError if read fails or numBytes is invalid
    static func readBytes(from fileHandle: FileHandle, address: Int, numBytes: Int = 1) throws -> Int {
        guard numBytes >= 1 && numBytes <= 3 else {
            throw BinaryIOError.invalidByteCount(numBytes)
        }

        // Seek to address
        try fileHandle.seek(toOffset: UInt64(address))

        // Read bytes
        guard let data = try fileHandle.read(upToCount: numBytes),
              data.count == numBytes else {
            throw BinaryIOError.readFailed(address: address, expected: numBytes, got: 0)
        }

        // Convert little-endian bytes to integer
        // We read the bytes in order, then interpret them as little-endian
        return data.withUnsafeBytes { ptr in
            switch numBytes {
            case 1:
                // Single byte: just return the value
                return Int(ptr.load(as: UInt8.self))

            case 2:
                // Two bytes: load as UInt16 and convert from little-endian
                let value = ptr.loadUnaligned(as: UInt16.self)
                return Int(UInt16(littleEndian: value))

            case 3:
                // Three bytes: pad to 4 bytes, then load as UInt32
                // Example: [0x3F, 0x42, 0x00] becomes [0x3F, 0x42, 0x00, 0x00]
                var bytes: [UInt8] = Array(repeating: 0, count: 4)
                bytes.replaceSubrange(0..<3, with: data[0..<3])
                let value = bytes.withUnsafeBytes {
                    $0.loadUnaligned(as: UInt32.self)
                }
                return Int(UInt32(littleEndian: value))

            default:
                fatalError("Unreachable: numBytes validated above")
            }
        }
    }

    /// Read fixed-length ASCII string from file (space-padded, like crew names)
    ///
    /// Crew member names are stored as 15-byte fixed-length ASCII strings,
    /// padded with spaces. This function reads the string and trims trailing spaces.
    ///
    /// Example:
    /// ```
    /// // File contains: "KIRK           " (15 bytes)
    /// let name = try BinaryFileIO.readString(from: fileHandle, address: 0x01C1, length: 15)
    /// // Result: "KIRK"
    /// ```
    ///
    /// - Parameters:
    ///   - fileHandle: Open file handle for reading
    ///   - address: Hex address to read from
    ///   - length: Number of bytes to read
    /// - Returns: String with trailing spaces removed
    /// - Throws: BinaryIOError if read fails or string cannot be decoded as ASCII
    static func readString(from fileHandle: FileHandle, address: Int, length: Int) throws -> String {
        try fileHandle.seek(toOffset: UInt64(address))

        guard let data = try fileHandle.read(upToCount: length),
              data.count == length else {
            throw BinaryIOError.readFailed(address: address, expected: length, got: 0)
        }

        // Decode ASCII and trim trailing spaces
        guard let string = String(data: data, encoding: .ascii) else {
            throw BinaryIOError.stringDecodingFailed(address: address)
        }

        return string.trimmingCharacters(in: .whitespaces)
    }

    // MARK: - Writing Operations

    /// Write 1-3 bytes to file at specific address (little-endian byte order)
    ///
    /// This is the core function for writing save game data. The save file format
    /// requires all multi-byte integers to be stored in little-endian format.
    ///
    /// Example:
    /// ```
    /// // Write value 16959 (0x00423F) as 3 bytes
    /// try BinaryFileIO.writeBytes(to: fileHandle, address: 0x024C, value: 16959, numBytes: 3)
    /// // File will contain: [0x3F, 0x42, 0x00] (little-endian)
    /// ```
    ///
    /// - Parameters:
    ///   - fileHandle: Open file handle for writing
    ///   - address: Hex address to write to
    ///   - value: Integer value to write (must fit in numBytes)
    ///   - numBytes: Number of bytes to write (1, 2, or 3)
    /// - Throws: BinaryIOError if value is out of range or write fails
    static func writeBytes(to fileHandle: FileHandle, address: Int, value: Int, numBytes: Int = 1) throws {
        guard numBytes >= 1 && numBytes <= 3 else {
            throw BinaryIOError.invalidByteCount(numBytes)
        }

        // Validate value fits in numBytes
        let maxValue = (1 << (numBytes * 8)) - 1
        guard value >= 0 && value <= maxValue else {
            throw BinaryIOError.valueOutOfRange(value: value, maxBytes: numBytes, maxValue: maxValue)
        }

        // Convert to little-endian bytes
        var data = Data()
        switch numBytes {
        case 1:
            // Single byte: just append the value
            data.append(UInt8(value))

        case 2:
            // Two bytes: convert to little-endian UInt16
            var littleValue = UInt16(value).littleEndian
            data.append(contentsOf: withUnsafeBytes(of: &littleValue) { Data($0) })

        case 3:
            // Three bytes: convert to little-endian UInt32, then take first 3 bytes
            var littleValue = UInt32(value).littleEndian
            data.append(contentsOf: withUnsafeBytes(of: &littleValue) { Data($0).prefix(3) })

        default:
            fatalError("Unreachable: numBytes validated above")
        }

        // Seek and write
        try fileHandle.seek(toOffset: UInt64(address))
        try fileHandle.write(contentsOf: data)
    }

    /// Write fixed-length string to file (space-padded)
    ///
    /// Crew member names must be exactly 15 bytes. This function pads short strings
    /// with spaces to reach the required length.
    ///
    /// Example:
    /// ```
    /// try BinaryFileIO.writeString(to: fileHandle, address: 0x01C1, value: "KIRK", length: 15)
    /// // File will contain: "KIRK           " (15 bytes)
    /// ```
    ///
    /// - Parameters:
    ///   - fileHandle: Open file handle for writing
    ///   - address: Hex address to write to
    ///   - value: String to write (must not exceed length)
    ///   - length: Fixed length of the string field
    /// - Throws: BinaryIOError if string is too long or cannot be encoded as ASCII
    static func writeString(to fileHandle: FileHandle, address: Int, value: String, length: Int) throws {
        guard value.count <= length else {
            throw BinaryIOError.stringTooLong(value: value, maxLength: length)
        }

        // Pad with spaces to reach required length
        let padded = value.padding(toLength: length, withPad: " ", startingAt: 0)
        guard let data = padded.data(using: .ascii) else {
            throw BinaryIOError.stringEncodingFailed(value: value)
        }

        try fileHandle.seek(toOffset: UInt64(address))
        try fileHandle.write(contentsOf: data)
    }
}

// MARK: - Error Types

/// Errors that can occur during binary file I/O operations
enum BinaryIOError: LocalizedError {
    case invalidByteCount(Int)
    case readFailed(address: Int, expected: Int, got: Int)
    case stringDecodingFailed(address: Int)
    case valueOutOfRange(value: Int, maxBytes: Int, maxValue: Int)
    case stringTooLong(value: String, maxLength: Int)
    case stringEncodingFailed(value: String)

    var errorDescription: String? {
        switch self {
        case .invalidByteCount(let count):
            return "Invalid byte count: \(count). Must be 1-3 bytes."

        case .readFailed(let addr, let expected, let got):
            return "Failed to read \(expected) bytes from address \(String(format: "0x%04X", addr)). Got \(got) bytes."

        case .stringDecodingFailed(let addr):
            return "Failed to decode ASCII string at address \(String(format: "0x%04X", addr))."

        case .valueOutOfRange(let val, let bytes, let maxVal):
            return "Value \(val) exceeds maximum for \(bytes) bytes (max: \(maxVal))."

        case .stringTooLong(let str, let max):
            return "String '\(str)' (\(str.count) chars) exceeds maximum length \(max)."

        case .stringEncodingFailed(let str):
            return "Failed to encode string '\(str)' as ASCII."
        }
    }
}
