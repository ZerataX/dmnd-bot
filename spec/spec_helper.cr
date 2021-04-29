require "spec"
require "../src/syncplay_bot"

DIR = Path.posix "./spec"

# Runs the the binary with the given *name* and *args*.
def run_binary(input : String? = nil, name : String = "bin/syncplay_bot", args : Array(String) = [] of String, &block : String, Process::Status, String -> Nil)
    buffer_io = IO::Memory.new
    error_io = IO::Memory.new
    input_io = IO::Memory.new
    input_io << input if input
    status = Process.run(name, args, output: buffer_io, input: input_io.rewind, error: error_io)
    yield buffer_io.to_s, status, error_io.to_s
  end