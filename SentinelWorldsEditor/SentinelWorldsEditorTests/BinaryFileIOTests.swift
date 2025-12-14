//
// BinaryFileIOTests.swift
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

import XCTest
@testable import SentinelWorldsEditor

/// Comprehensive tests for BinaryFileIO
///
/// These tests are CRITICAL to verify little-endian byte order handling.
/// If these tests pass, we can be confident that the binary I/O layer is correct.
final class BinaryFileIOTests: XCTestCase {

    var testFileURL: URL!

    override func setUp() {
        super.setUp()
        // Create temporary test file
        testFileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("test_binary_\(UUID().uuidString).dat")
    }

    override func tearDown() {
        // Clean up test file
        try? FileManager.default.removeItem(at: testFileURL)
        super.tearDown()
    }

    // MARK: - Single Byte Tests

    func testReadSingleByte() throws {
        // Create test file with known data
        let testData = Data([0x3F, 0x42, 0x00, 0xFF, 0xFE])
        try testData.write(to: testFileURL)

        let fileHandle = try FileHandle(forReadingFrom: testFileURL)
        defer { try? fileHandle.close() }

        // Read first byte
        let value = try BinaryFileIO.readBytes(from: fileHandle, address: 0, numBytes: 1)
        XCTAssertEqual(value, 0x3F, "Should read first byte as 0x3F (63)")

        // Read byte at offset 3
        let value2 = try BinaryFileIO.readBytes(from: fileHandle, address: 3, numBytes: 1)
        XCTAssertEqual(value2, 0xFF, "Should read byte at offset 3 as 0xFF (255)")
    }

    func testWriteSingleByte() throws {
        // Create empty test file
        try Data(repeating: 0x00, count: 10).write(to: testFileURL)

        let fileHandle = try FileHandle(forUpdating: testFileURL)
        defer { try? fileHandle.close() }

        // Write byte
        try BinaryFileIO.writeBytes(to: fileHandle, address: 5, value: 0xAB, numBytes: 1)

        // Verify by reading back
        let readHandle = try FileHandle(forReadingFrom: testFileURL)
        try readHandle.seek(toOffset: 5)
        let data = try readHandle.read(upToCount: 1)
        try? readHandle.close()

        XCTAssertEqual(data, Data([0xAB]), "Written byte should match")
    }

    // MARK: - Two-Byte Little-Endian Tests

    func testReadTwoBytes_LittleEndian() throws {
        // CRITICAL TEST: Verify little-endian byte order
        // Bytes [0x3F, 0x42] should be read as 0x423F (16959), NOT 0x3F42 (16194)
        let testData = Data([0x3F, 0x42, 0x00])
        try testData.write(to: testFileURL)

        let fileHandle = try FileHandle(forReadingFrom: testFileURL)
        defer { try? fileHandle.close() }

        let value = try BinaryFileIO.readBytes(from: fileHandle, address: 0, numBytes: 2)

        // This is the CRITICAL assertion
        XCTAssertEqual(value, 0x423F, "Little-endian: [0x3F, 0x42] should read as 0x423F (16959)")
        XCTAssertNotEqual(value, 0x3F42, "Must NOT read as big-endian 0x3F42 (16194)")
        XCTAssertEqual(value, 16959, "Decimal value should be 16959")
    }

    func testWriteTwoBytes_LittleEndian() throws {
        // CRITICAL TEST: Verify little-endian write
        // Value 0x423F (16959) should be written as bytes [0x3F, 0x42]
        try Data(repeating: 0x00, count: 10).write(to: testFileURL)

        let fileHandle = try FileHandle(forUpdating: testFileURL)
        defer { try? fileHandle.close() }

        // Write value 16959 (0x423F) as 2 bytes
        try BinaryFileIO.writeBytes(to: fileHandle, address: 0, value: 16959, numBytes: 2)

        // Read back raw bytes
        let readHandle = try FileHandle(forReadingFrom: testFileURL)
        let data = try readHandle.read(upToCount: 2)
        try? readHandle.close()

        // Verify bytes are in little-endian order
        XCTAssertEqual(data, Data([0x3F, 0x42]), "Value 16959 should write as [0x3F, 0x42] (little-endian)")
    }

    // MARK: - Three-Byte Little-Endian Tests

    func testReadThreeBytes_LittleEndian() throws {
        // CRITICAL TEST: Three-byte little-endian
        // Bytes [0x3F, 0x42, 0x00] should be read as 0x00423F (16959)
        let testData = Data([0x3F, 0x42, 0x00, 0xFF])
        try testData.write(to: testFileURL)

        let fileHandle = try FileHandle(forReadingFrom: testFileURL)
        defer { try? fileHandle.close() }

        let value = try BinaryFileIO.readBytes(from: fileHandle, address: 0, numBytes: 3)

        XCTAssertEqual(value, 0x00423F, "Little-endian: [0x3F, 0x42, 0x00] should read as 0x00423F")
        XCTAssertEqual(value, 16959, "Decimal value should be 16959")
    }

    func testReadThreeBytes_MaxValue() throws {
        // Test maximum 3-byte value: 0xFFFFFF (16,777,215)
        let testData = Data([0xFF, 0xFF, 0xFF, 0x00])
        try testData.write(to: testFileURL)

        let fileHandle = try FileHandle(forReadingFrom: testFileURL)
        defer { try? fileHandle.close() }

        let value = try BinaryFileIO.readBytes(from: fileHandle, address: 0, numBytes: 3)

        XCTAssertEqual(value, 16777215, "Maximum 3-byte value should be 16,777,215")
    }

    func testWriteThreeBytes_LittleEndian() throws {
        // CRITICAL TEST: Three-byte little-endian write
        // Value 16959 (0x00423F) should be written as [0x3F, 0x42, 0x00]
        try Data(repeating: 0x00, count: 10).write(to: testFileURL)

        let fileHandle = try FileHandle(forUpdating: testFileURL)
        defer { try? fileHandle.close() }

        try BinaryFileIO.writeBytes(to: fileHandle, address: 0, value: 16959, numBytes: 3)

        // Read back raw bytes
        let readHandle = try FileHandle(forReadingFrom: testFileURL)
        let data = try readHandle.read(upToCount: 3)
        try? readHandle.close()

        XCTAssertEqual(data, Data([0x3F, 0x42, 0x00]), "Value 16959 should write as [0x3F, 0x42, 0x00]")
    }

    // MARK: - Round-Trip Tests

    func testRoundTrip_OneByte() throws {
        try Data(repeating: 0x00, count: 10).write(to: testFileURL)
        let fileHandle = try FileHandle(forUpdating: testFileURL)
        defer { try? fileHandle.close() }

        let originalValue = 254
        try BinaryFileIO.writeBytes(to: fileHandle, address: 5, value: originalValue, numBytes: 1)

        let readValue = try BinaryFileIO.readBytes(from: fileHandle, address: 5, numBytes: 1)
        XCTAssertEqual(readValue, originalValue, "Round-trip 1-byte: write then read should preserve value")
    }

    func testRoundTrip_TwoBytes() throws {
        try Data(repeating: 0x00, count: 10).write(to: testFileURL)
        let fileHandle = try FileHandle(forUpdating: testFileURL)
        defer { try? fileHandle.close() }

        let originalValue = 12345
        try BinaryFileIO.writeBytes(to: fileHandle, address: 0, value: originalValue, numBytes: 2)

        let readValue = try BinaryFileIO.readBytes(from: fileHandle, address: 0, numBytes: 2)
        XCTAssertEqual(readValue, originalValue, "Round-trip 2-byte: write then read should preserve value")
    }

    func testRoundTrip_ThreeBytes() throws {
        try Data(repeating: 0x00, count: 10).write(to: testFileURL)
        let fileHandle = try FileHandle(forUpdating: testFileURL)
        defer { try? fileHandle.close() }

        let originalValue = 655359  // Max cash value for party
        try BinaryFileIO.writeBytes(to: fileHandle, address: 0, value: originalValue, numBytes: 3)

        let readValue = try BinaryFileIO.readBytes(from: fileHandle, address: 0, numBytes: 3)
        XCTAssertEqual(readValue, originalValue, "Round-trip 3-byte: write then read should preserve value (655359)")
    }

    // MARK: - String Tests

    func testReadString_WithSpaces() throws {
        // Create test file with space-padded string
        let testString = "KIRK           "  // 15 bytes
        let testData = testString.data(using: .ascii)!
        try testData.write(to: testFileURL)

        let fileHandle = try FileHandle(forReadingFrom: testFileURL)
        defer { try? fileHandle.close() }

        let value = try BinaryFileIO.readString(from: fileHandle, address: 0, length: 15)
        XCTAssertEqual(value, "KIRK", "Should trim trailing spaces")
    }

    func testReadString_NoSpaces() throws {
        let testString = "SPOCK"
        let testData = testString.data(using: .ascii)!
        try testData.write(to: testFileURL)

        let fileHandle = try FileHandle(forReadingFrom: testFileURL)
        defer { try? fileHandle.close() }

        let value = try BinaryFileIO.readString(from: fileHandle, address: 0, length: 5)
        XCTAssertEqual(value, "SPOCK", "Should read string without modification if no trailing spaces")
    }

    func testWriteString_Padded() throws {
        try Data(repeating: 0x00, count: 20).write(to: testFileURL)

        let fileHandle = try FileHandle(forUpdating: testFileURL)
        defer { try? fileHandle.close() }

        try BinaryFileIO.writeString(to: fileHandle, address: 0, value: "TEST", length: 10)

        // Read back raw bytes
        let readHandle = try FileHandle(forReadingFrom: testFileURL)
        let data = try readHandle.read(upToCount: 10)
        try? readHandle.close()

        let expected = "TEST      ".data(using: .ascii)!
        XCTAssertEqual(data, expected, "Should pad with spaces to reach length")
    }

    func testWriteString_ExactLength() throws {
        try Data(repeating: 0x00, count: 20).write(to: testFileURL)

        let fileHandle = try FileHandle(forUpdating: testFileURL)
        defer { try? fileHandle.close() }

        try BinaryFileIO.writeString(to: fileHandle, address: 0, value: "ABCDEFGHIJ", length: 10)

        let readValue = try BinaryFileIO.readString(from: fileHandle, address: 0, length: 10)
        XCTAssertEqual(readValue, "ABCDEFGHIJ", "Should handle exact-length strings")
    }

    func testStringRoundTrip() throws {
        try Data(repeating: 0x00, count: 20).write(to: testFileURL)

        let fileHandle = try FileHandle(forUpdating: testFileURL)
        defer { try? fileHandle.close() }

        let originalName = "MCCOY"
        try BinaryFileIO.writeString(to: fileHandle, address: 0, value: originalName, length: 15)

        let readName = try BinaryFileIO.readString(from: fileHandle, address: 0, length: 15)
        XCTAssertEqual(readName, originalName, "Round-trip string: write then read should preserve value")
    }

    // MARK: - Error Handling Tests

    func testInvalidByteCount() throws {
        let testData = Data([0x00, 0x00, 0x00])
        try testData.write(to: testFileURL)

        let fileHandle = try FileHandle(forReadingFrom: testFileURL)
        defer { try? fileHandle.close() }

        // Test invalid byte counts
        XCTAssertThrowsError(try BinaryFileIO.readBytes(from: fileHandle, address: 0, numBytes: 0))
        XCTAssertThrowsError(try BinaryFileIO.readBytes(from: fileHandle, address: 0, numBytes: 4))
    }

    func testValueOutOfRange() throws {
        try Data(repeating: 0x00, count: 10).write(to: testFileURL)

        let fileHandle = try FileHandle(forUpdating: testFileURL)
        defer { try? fileHandle.close() }

        // Try to write value that's too large for 1 byte
        XCTAssertThrowsError(try BinaryFileIO.writeBytes(to: fileHandle, address: 0, value: 256, numBytes: 1))

        // Try to write value that's too large for 2 bytes
        XCTAssertThrowsError(try BinaryFileIO.writeBytes(to: fileHandle, address: 0, value: 65536, numBytes: 2))
    }

    func testStringTooLong() throws {
        try Data(repeating: 0x00, count: 10).write(to: testFileURL)

        let fileHandle = try FileHandle(forUpdating: testFileURL)
        defer { try? fileHandle.close() }

        // Try to write string longer than specified length
        XCTAssertThrowsError(try BinaryFileIO.writeString(to: fileHandle, address: 0, value: "TOOLONGNAME", length: 5))
    }

    // MARK: - Integration Test with Real Save File (if available)

    func testRealSaveFile_PartyCash() throws {
        // This test uses the actual game save file from test_data/
        let projectRoot = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()  // Tests directory
            .deletingLastPathComponent()  // SentinelWorldsEditor directory
            .deletingLastPathComponent()  // Repository root

        let saveFileURL = projectRoot
            .appendingPathComponent("test_data")
            .appendingPathComponent("GAMEA.FM")

        // Skip test if save file doesn't exist
        guard FileManager.default.fileExists(atPath: saveFileURL.path) else {
            throw XCTSkip("Test save file not found at \(saveFileURL.path)")
        }

        let fileHandle = try FileHandle(forReadingFrom: saveFileURL)
        defer { try? fileHandle.close() }

        // Read party cash (3 bytes at address 0x024C)
        let cash = try BinaryFileIO.readBytes(from: fileHandle, address: 0x024C, numBytes: 3)

        // Party cash should be a reasonable value (0 to 655,359)
        XCTAssertGreaterThanOrEqual(cash, 0, "Party cash should be non-negative")
        XCTAssertLessThanOrEqual(cash, 655359, "Party cash should not exceed maximum (655,359)")

        print("✅ Real save file test: Party cash = \(cash)")
    }
}
