# StreamKit

StreamKit is a cross-platform stream library written in pure Swift. It is intended to make the handling of data streams much easier.

It is currently in the development stage, and not ready for production use.

Currently provided is the `Stream` protocol, with basic functions such as `read()`, `write()`, and `close()`.

I am looking for community input on the project. I intend for this library to be widely used, so API design is crucial.

## Usage
For usage information, check the [wiki](https://github.com/eswick/StreamKit/wiki).

## Checklist

- [ ] Streams
  - [x] IOStream (read/write to UNIX file descriptors)
  - [x] File Stream (read/write to files)
  - [ ] Memory Stream (read/write to byte array)
  - [ ] Compression Streams
    - [ ] Deflate
    - [ ] Gzip
    - [ ] LZMA
- [ ] Base Protocol
  - [x] Shorthand Operators
    - [x] `<<`
    - [x] `>>`
  - [ ] Data Type Support
    - [x] UInt8
    - [x] UInt16
    - [x] UInt32
    - [x] UInt64
    - [x] Int8
    - [x] Int16
    - [x] Int32
    - [x] Int64
    - [x] Float
    - [x] Double
    - [x] Bool
    - [ ] String
  - [x] Read
  - [x] Write
  - [x] Close
  - [x] Seek
  - [x] Timeouts
