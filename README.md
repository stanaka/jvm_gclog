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

## Support options

### java 1.8 G1GC
```
% java -version
java version "1.8.0_40"
Java(TM) SE Runtime Environment (build 1.8.0_40-b25)
Java HotSpot(TM) 64-Bit Server VM (build 25.40-b25, mixed mode)
```

```
-XX:+PrintGCDetails
-XX:+PrintGCTimeStamps
-XX:+PrintTenuringDistribution
-XX:+PrintGCApplicationStoppedTime
-XX:+DisableExplicitGC
-XX:+PrintGCDetails
-XX:+PrintGCDateStamps
-XX:+UseG1GC
```

### java 1.7 CMS
```
% java -version
java version "1.7.0_65"
Java(TM) SE Runtime Environment (build 1.7.0_65-b17)
Java HotSpot(TM) 64-Bit Server VM (build 24.65-b04, mixed mode)
```

```
-XX:+UseConcMarkSweepGC
-XX:+CMSIncrementalMode
-XX:+PrintGCDetails
-XX:+PrintGCDateStamps
-XX:+UseGCLogFileRotation
-XX:NumberOfGCLogFiles=5
-XX:GCLogFileSize=10M
```
