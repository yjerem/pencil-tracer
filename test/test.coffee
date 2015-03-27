# This script goes through each test in the test/traces directory, does a trace
# on that test program, and compares the result with an expected trace that is
# specified in a special comment in the test program.
#
# The special comment looks like "# Expected: [1, 2, enter 3, leave 3]", where
# the array is an array of line numbers and enter/leave events that's expected
# to correspond to the actual events array.

fs = require "fs"
path = require "path"
vm = require "vm"

{instrument} = require "../lib/index"

# From http://stackoverflow.com/questions/11142666
arrayEqual = (a, b) ->
  a.length is b.length and a.every (elem, i) -> elem is b[i]

# Loop through files in test/traces directory.
tracesDir = path.join(path.dirname(__filename), "traces")
traceFiles = fs.readdirSync tracesDir
for traceFile in traceFiles
  # Skip non-CS files that might be in there (like .swp files).
  continue unless /\.coffee$/.test traceFile

  # Get code and instrument it.
  code = fs.readFileSync path.join(tracesDir, traceFile), "utf-8"
  js = instrument traceFile, code

  # Run instrumented code in sandbox, collecting the events.
  sandbox =
    ide:
      events: [],
      trace: (event) -> sandbox.ide.events.push(event)
  vm.runInContext(js, vm.createContext(sandbox))

  # Find the expected line numbers of the trace.
  matches = code.match /^# Expected: (.+)$/m

  # Evaluate the expected value, which is a tiny DSL.
  enter = (lineNum) -> "enter #{lineNum}"
  leave = (lineNum) -> "leave #{lineNum}"
  expected = eval(matches[1])

  # The actual array of events will be mapped over with this function.
  summarizeEvent = (event) ->
    if event.type is ""
      event.location.first_line
    else
      "#{event.type} #{event.location.first_line}"

  # Put the actual result in the same form as the expected one, so they can be
  # compared.
  actual = (summarizeEvent(event) for event in sandbox.ide.events)

  # Compare actual and expected.
  if arrayEqual(actual, expected)
    console.log "PASSED: test/traces/#{traceFile}"
  else
    console.log "FAILED: test/traces/#{traceFile}"
    console.log "  Expected: #{expected}"
    console.log "  Actual:   #{actual}"
