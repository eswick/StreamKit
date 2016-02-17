# StreamKit

StreamKit is a cross-platform stream library written in pure Swift. It is intended to make the handling of data streams much easier.

It is currently in the development stage, and not ready for production use.

Currently provided is the Stream protocol, with basic functions such as `read()`, `write()`, and `close()`.

I am looking for community input on the project. I intend for this library to be widely used, so API design is crucial.

## Usage
For usage information, check the [wiki](https://github.com/eswick/StreamKit/wiki).

## Checklist

- [ ] Streams
  - [ ] IOStream
    - Read/write to UNIX file descriptors
    - [x] Read
    - [x] Write
    - [x] Close
    - [ ] Seek
  - [ ] File Stream
    - Wrapper around IOStream for the filesystem
    - [ ] Read
    - [ ] Write
    - [ ] Close
    - [ ] Seek
  - [ ] Memory Stream
    - Read/write to byte array
    - [ ] Read
    - [ ] Write
    - [ ] Close
    - [ ] Seek
  - [ ] Compression Streams
    - [ ] Deflate
      - [ ] Read
      - [ ] Write
      - [ ] Close
      - [ ] Seek
    - [ ] Gzip
      - [ ] Read
      - [ ] Write
      - [ ] Close
      - [ ] Seek
    - [ ] LZMA
      - [ ] Read
      - [ ] Write
      - [ ] Close
      - [ ] Seek
- Base Protocol
  - [x] Shorthand Operators
    - [x] `<<`
    - [x] `>>`
  - [ ] Data Type Support
    - [x] UInt8
    - [ ] UInt16
    - [ ] UInt32
    - [ ] UInt64
    - [x] Int8
    - [ ] Int16
    - [ ] Int32
    - [ ] Int64
    - [ ] Float
    - [ ] Double
    - [ ] Bool
    - [x] String
  - [x] Read
  - [x] Write
  - [x] Close
  - [ ] Seek
