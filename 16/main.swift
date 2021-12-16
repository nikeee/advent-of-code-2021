// Compile:
//     swiftc -O main.swift
// Run:
//     ./main < input.txt
// Compiler version:
//     swiftc --version
//     Swift version 5.5.2 (swift-5.5.2-RELEASE)

import Foundation

let data = readLine(strippingNewline: true)!
let bits = dataToBitString(data)

let (_, rootPacket) = parsePacket(bits)

let part1Solution = computeVersionSum(rootPacket)
print("Sum of packet versions; Part 1: \(part1Solution)")

let part2Solution = evaluatePacketExpression(rootPacket)
print("Evaluated expression described py packets; Part 2: \(part2Solution)")

enum Packet {
	case literal(_ version: Int, value: Int64)
	// We could create a case for every package type, but since they are all pretty similar, we don't want to have a lot of boilerplate
	case operational(_ version: Int, _ type: Action, subPackets: [Packet])
}

enum Action : Int {
	case sum = 0
	case product = 1
	case min = 2
	case max = 3
	case gt = 5
	case lt = 6
	case eq = 7
}

func computeVersionSum(_ packet: Packet) -> Int {
	switch packet {
		case .literal(let version, _): return version
		case .operational(let version, _, let subPackets):
			return subPackets.reduce(
					version,
					{ x, packet in x + computeVersionSum(packet) }
				)
	}
}

func evaluatePacketExpression(_ packet: Packet) -> Int64 {
	switch packet {
		case .literal(_, let value): return value
		case .operational(_, let type, let subPackets):
			switch type {
				case .sum:
					return subPackets.reduce(0, { x, packet in x + evaluatePacketExpression(packet) })
				case .product:
					return subPackets.reduce(1, { x, packet in x * evaluatePacketExpression(packet) })
				case .min:
					return subPackets.map { evaluatePacketExpression($0) }.min()!
				case .max:
					return subPackets.map { evaluatePacketExpression($0) }.max()!
				case .gt:
					return evaluatePacketExpression(subPackets[0]) > evaluatePacketExpression(subPackets[1]) ? 1 : 0
				case .lt:
					return evaluatePacketExpression(subPackets[0]) < evaluatePacketExpression(subPackets[1]) ? 1 : 0
				case .eq:
					return evaluatePacketExpression(subPackets[0]) == evaluatePacketExpression(subPackets[1]) ? 1 : 0
			}
	}
}

func parsePacket(_ bits: String) -> (offset: Int, Packet) {
	var offset = 0

	let version = parseInt(bits, offset, length: 3)
	offset += 3

	let typeId = parseInt(bits, offset, length: 3)
	offset += 3

	switch typeId {
		case 4:
			var literalValueString = ""

			var isLastNibble = false;
			repeat {
				isLastNibble = parseInt(bits, offset, length: 1) == 0
				offset += 1

				literalValueString += bits[offset..<offset + 4]
				offset += 4

			} while !isLastNibble

			let value = parseInt64(literalValueString, 0, length: literalValueString.length)

			return (offset, Packet.literal(version, value: value))
		default:
			let lengthTypeId = parseInt(bits, offset, length: 1)
			offset += 1

			switch lengthTypeId {
				case 0:
					let innerDataLength = parseInt(bits, offset, length: 15)
					offset += 15

					let targetOffset = offset + innerDataLength

					var subPackets: [Packet] = []
					while offset < targetOffset {
						let innerData = bits[offset..<targetOffset]
						let (bitsRead, subPacket) = parsePacket(innerData)
						subPackets.append(subPacket)
						offset += bitsRead
					}

					return (offset, Packet.operational(version, Action(rawValue: typeId)!, subPackets: subPackets))
				case 1:
					let numberOfSubPackets = parseInt(bits, offset, length: 11)
					offset += 11

					var subPackets: [Packet] = []
					for _ in 0..<numberOfSubPackets {
						let innerData = bits[offset...]
						let (bitsRead, subPacket) = parsePacket(innerData)
						subPackets.append(subPacket)
						offset += bitsRead
					}

					return (offset, Packet.operational(version, Action(rawValue: typeId)!, subPackets: subPackets))
				default:
					abort()
			}
	}
}

func parseInt(_ bits: String, _ start: Int, length: Int) -> Int {
	let str = bits[start..<start + length]
	return Int(str, radix: 2)!
}
func parseInt64(_ bits: String, _ start: Int, length: Int) -> Int64 {
	let str = bits[start..<start + length]
	return Int64(str, radix: 2)!
}

func dataToBitString(_ data: String) -> String {
	// We're building this the "cheap" way
	// Instead of reading the input into some BitArray type (or even a byte buffer),
	// We're working with plain strings, so we don't need dependencies and don't have to write much code
	let charDecodeMap: [Character : String] = [
		"0": "0000",
		"1": "0001",
		"2": "0010",
		"3": "0011",
		"4": "0100",
		"5": "0101",
		"6": "0110",
		"7": "0111",
		"8": "1000",
		"9": "1001",
		"A": "1010",
		"B": "1011",
		"C": "1100",
		"D": "1101",
		"E": "1110",
		"F": "1111",
	]

	// We're also not using some "0123456789ABCDEF".firstIndex logic, so we don't have to pad the output to alway<s match a nibble.
	return data.map { charDecodeMap[$0]! }.joined()
}

// Taken and modified from: https://stackoverflow.com/a/26775912
extension String {
	var length: Int {
		return count
	}

	subscript (i: Int) -> String {
		return self[i..<(i + 1)]
	}

	func substring(fromIndex: Int) -> String {
		return self[min(fromIndex, length)..<length]
	}

	func substring(toIndex: Int) -> String {
		return self[0..<max(0, toIndex)]
	}

	subscript (r: Range<Int>) -> String {
		let range = Range(
			uncheckedBounds: (
				lower: max(0, min(length, r.lowerBound)),
				upper: min(length, max(0, r.upperBound))
			)
		)
		let start = index(startIndex, offsetBy: range.lowerBound)
		let end = index(start, offsetBy: range.upperBound - range.lowerBound)
		return String(self[start..<end])
	}

	subscript (r: PartialRangeFrom<Int>) -> String {
		return self[r.lowerBound..<length]
	}
}
