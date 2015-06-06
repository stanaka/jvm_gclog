# -*- coding: utf-8 -*-

require "spec_helper"

describe "JVMGCLog" do
  before :each do
    @jvmgclog = JVMGCLog.new
  end

  describe "#parse" do
    context "given log" do
      describe "YoungGC" do
        before :each do
          @line = "2015-06-05T13:15:32.483+0900: 48.974: [GC2015-06-05T13:15:32.483+0900: 48.974: [ParNew: 886367K->1031K(996800K), 0.0096570 secs] 896432K->11133K(4083584K) icms_dc=0 , 0.0098390 secs] [Times: user=0.10 sys=0.00, real=0.01 secs] "
          @r = @jvmgclog.parse(@line)
        end

        it "should have expected values" do
          expect(@r["time"]).to eq 1433477732
          expect(@r["type"]).to eq "YoungGC"
          expect(@r["uptime"]).to eq 48.974
          expect(@r["new_before"]).to eq 886367
          expect(@r["new_after"]).to eq 1031
          expect(@r["new_total"]).to eq 996800
          expect(@r["new_gctime"]).to eq 0.009657
          expect(@r["heap_before"]).to eq 896432
          expect(@r["heap_after"]).to eq 11133
          expect(@r["heap_total"]).to eq 4083584
          expect(@r["icms_dc"]).to eq 0
          expect(@r["gctime_user"]).to eq 0.1
          expect(@r["gctime_sys"]).to eq 0.00
          expect(@r["gctime_real"]).to eq 0.01
        end
      end

      describe "CMS-initial-mark" do
        before :each do
          @line = "2015-06-05T13:15:27.747+0900: 44.239: [GC [1 CMS-initial-mark: 0K(3086784K)] 445450K(4083584K), 0.0298540 secs] [Times: user=0.04 sys=0.00, real=0.04 secs] "
          @r = @jvmgclog.parse(@line)
        end

        it "should have expected values" do
          expect(@r["time"]).to eq 1433477727
          expect(@r["type"]).to eq "CMS-initial-mark"
          expect(@r["uptime"]).to eq 44.239
          expect(@r["old_before"]).to eq 0
          expect(@r["old_threshold"]).to eq 3086784
          expect(@r["heap_before"]).to eq 445450
          expect(@r["heap_total"]).to eq 4083584
          expect(@r["gctime_user"]).to eq 0.04
          expect(@r["gctime_sys"]).to eq 0.00
          expect(@r["gctime_real"]).to eq 0.04
        end
      end

      describe "CMS-parallel-remark" do
        before :each do
          @line = "2015-06-05T13:15:29.600+0900: 46.091: [GC[YG occupancy: 454149 K (996800 K)]2015-06-05T13:15:29.600+0900: 46.091: [Rescan (parallel) , 0.0082970 secs]2015-06-05T13:15:29.608+0900: 46.099: [weak refs processing, 0.0000930 secs]2015-06-05T13:15:29.608+0900: 46.099: [scrub string table, 0.0007250 secs] [1 CMS-remark: 0K(3086784K)] 454149K(4083584K), 0.0094230 secs] [Times: user=0.09 sys=0.00, real=0.01 secs] "
          @r = @jvmgclog.parse(@line)
        end

        it "should have expected values" do
          expect(@r["time"]).to eq 1433477729
          expect(@r["type"]).to eq "CMS-parallel-remark"
          expect(@r["uptime"]).to eq 46.091
          expect(@r["new_before"]).to eq 454149
          expect(@r["new_threshold"]).to eq 996800
          expect(@r["old_before"]).to eq 0
          expect(@r["old_threshold"]).to eq 3086784
          expect(@r["heap_before"]).to eq 454149
          expect(@r["heap_total"]).to eq 4083584
          expect(@r["gctime_user"]).to eq 0.09
          expect(@r["gctime_sys"]).to eq 0.00
          expect(@r["gctime_real"]).to eq 0.01
        end
      end

      describe "FullGC-CMS-failure" do
        before :each do
          @line = "2015-05-20T12:24:11.125+0900: 224.659: [Full GC2015-05-20T12:24:11.126+0900: 224.659: [CMS2016-05-20T12:24:11.126+0900: 224.659: [CMS-concurrent-mark: 1.832/1.836 secs] [Times: user=1.51 sys=0.27, real=1.74 secs] (concurrent mode failure): 39203K->39203K(39204K), 1.8507640 secs] 15775K->58321K(315776K), [CMS Perm : 7066K->7066K(65544K)], 1.8509456 secs]"
          @r = @jvmgclog.parse(@line)
        end

        it "should have expected values" do
          expect(@r["time"]).to eq 1432092251
          expect(@r["type"]).to eq "FullGC-CMS-failure"
          expect(@r["uptime"]).to eq 224.659
          expect(@r["gctime"]).to eq 1.8509456
        end
      end

      describe "FullGC" do
        before :each do
          @line = "2014-08-19T14:44:08.807+0900: 513893.067: [Full GC [PSYoungGen: 43826K->0K(632832K)] [ParOldGen: 1375468K->149900K(1398272K)] 1419294K->149900K(2031104K) [PSPermGen: 95192K->95192K(95232K)], 0.6923610 secs] [Times: user=5.42 sys=0.00, real=0.69 secs] "
          @r = @jvmgclog.parse(@line)
        end

        it "should have expected values" do
          expect(@r["time"]).to eq 1408427048
          expect(@r["type"]).to eq "FullGC"
          expect(@r["uptime"]).to eq 513893.067
          expect(@r["gctime"]).to eq 0.6923610
          expect(@r["gctime_user"]).to eq 5.42
          expect(@r["gctime_sys"]).to eq 0.00
          expect(@r["gctime_real"]).to eq 0.69
        end
      end

      describe "CMS-concurrent-mark-start" do
        before :each do
          @line = "2015-06-05T13:15:27.778+0900: 44.269: [CMS-concurrent-mark-start]"
          @r = @jvmgclog.parse(@line)
        end

        it "should have expected values" do
          expect(@r["time"]).to eq 1433477727
          expect(@r["type"]).to eq "CMS-concurrent-mark-start"
          expect(@r["uptime"]).to eq 44.269
        end
      end

      describe "CMS-concurrent-mark" do
        before :each do
          @line = "2015-06-05T13:15:27.815+0900: 44.307: [CMS-concurrent-mark: 0.033/0.038 secs] [Times: user=0.08 sys=0.00, real=0.03 secs] "
          @r = @jvmgclog.parse(@line)
        end

        it "should have expected values" do
          expect(@r["time"]).to eq 1433477727
          expect(@r["type"]).to eq "CMS-concurrent-mark"
          expect(@r["uptime"]).to eq 44.307
          expect(@r["time_cpu"]).to eq 0.033
          expect(@r["time_wall"]).to eq 0.038
          expect(@r["gctime_user"]).to eq 0.08
          expect(@r["gctime_sys"]).to eq 0.00
          expect(@r["gctime_real"]).to eq 0.03
        end
      end

      describe "CMS-concurrent-preclean" do
        before :each do
          @line = "2015-06-05T13:15:27.835+0900: 44.326: [CMS-concurrent-preclean: 0.018/0.019 secs] [Times: user=0.03 sys=0.00, real=0.02 secs] "
          @r = @jvmgclog.parse(@line)
        end

        it "should have expected values" do
          expect(@r["time"]).to eq 1433477727
          expect(@r["type"]).to eq "CMS-concurrent-preclean"
          expect(@r["uptime"]).to eq 44.326
          expect(@r["time_cpu"]).to eq 0.018
          expect(@r["time_wall"]).to eq 0.019
          expect(@r["gctime_user"]).to eq 0.03
          expect(@r["gctime_sys"]).to eq 0.00
          expect(@r["gctime_real"]).to eq 0.02
        end
      end
      
    end
  end
end
