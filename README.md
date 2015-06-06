# jvm_gclog [![Build Status](https://travis-ci.org/stanaka/jvm_gclog.svg?branch=master)](https://travis-ci.org/stanaka/jvm_gclog)
A ruby parser for gc.log of JavaVM

## Usage

```ruby
line = "2014-08-19T14:44:08.807+0900: 513893.067: [Full GC [PSYoungGen: 43826K->0K(632832K)] [ParOldGen: 1375468K->149900K(1398272K)] 1419294K->149900K(2031104K) [PSPermGen: 95192K->95192K(95232K)], 0.6923610 secs] [Times: user=5.42 sys=0.00, real=0.69 secs] "
jvmgclog = JVMGCLog.new
record = JVMGCLog.parse(line)
```

```ruby
record = {
  "time" => 1408427048,
  "type" => "FullGC",
  "uptime" => 513893.067,
  "gctime" => 0.6923610,
  "gctime_user" => 5.42,
  "gctime_sys"=> 0.00,
  "gctime_real" => 0.69,
}
