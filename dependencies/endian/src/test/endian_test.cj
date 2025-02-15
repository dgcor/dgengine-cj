package endian.test

import endian.*
import endian.utils.*
import std.binary.*
import std.io.*
import std.unittest.*

let data: Array<Byte> = [2, 0, 0, 0, 0, 0, 0, 2, 1, 2, 3]

@Test
class TestBigEndianReader {
    @TestCase
    func test_BigEndianReader() {
        let byteArrayStream = ByteArrayStream()
        byteArrayStream.write(data)
        let reader = BigEndianReader(byteArrayStream)

        var value = reader.read<Int32>()
        @Expect(value.isSome(), true)
        @Expect(value.getOrThrow(), 33554432)

        value = reader.read()
        @Expect(value.isSome(), true)
        @Expect(value.getOrThrow(), 2)

        value = reader.read()
        @Expect(value.isNone(), true)
    }
}

@Test
class TestLittleEndianReader {
    @TestCase
    func test_LittleEndianReader() {
        let byteArrayStream = ByteArrayStream()
        byteArrayStream.write(data)
        let reader = LittleEndianReader(byteArrayStream)

        var value = reader.read<Int32>()
        @Expect(value.isSome(), true)
        @Expect(value.getOrThrow(), 2)

        value = reader.read()
        @Expect(value.isSome(), true)
        @Expect(value.getOrThrow(), 33554432)

        value = reader.read()
        @Expect(value.isNone(), true)
    }
}

@Test
class TestEndianReader {
    @TestCase
    func test_EndianReader() {
        let byteArrayStream = ByteArrayStream()
        byteArrayStream.write(data)
        let reader = EndianReader(byteArrayStream)

        var value = reader.read<Int32>()
        @Expect(value.isSome(), true)
        match (Endian.Platform) {
            case Big => @Expect(value.getOrThrow(), 33554432)
            case Little => @Expect(value.getOrThrow(), 2)
        }
        @Expect(value.getOrThrow(), 2)

        value = reader.read()
        @Expect(value.isSome(), true)
        match (Endian.Platform) {
            case Big => @Expect(value.getOrThrow(), 2)
            case Little => @Expect(value.getOrThrow(), 33554432)
        }

        value = reader.read()
        @Expect(value.isNone(), true)
    }
}

@Test
class TestReadEndian {
    @TestCase
    func ReadEndian() {
        let arr: Array<Byte> = [2, 0, 0, 0]
        let value = @ReadEndian[Int32](arr)
        match (Endian.Platform) {
            case Big => @Expect(value, 33554432)
            case Little => @Expect(value, 2)
        }
    }
}
