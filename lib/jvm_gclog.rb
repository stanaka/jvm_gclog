require 'time'

class JVMGCLog
  def adjust_type(value)
    if value =~ /^\d+\.\d+$/
      return value.to_f
    else
      return value.to_i
    end
  end
  
  def parse(line)
    record = Hash.new
    m = line.match(/^(?<time>[^ ]+): (?<uptime>[\d\.]+): (?<body>.+)$/)
    record["time"] = Time.parse(m[:time]).to_i
    record["uptime"] = adjust_type(m["uptime"])
    
    post_times = m[:body].match(/ \[Times: user=(?<gctime_user>[\d\.]+) sys=(?<gctime_sys>[\d\.]+), real=(?<gctime_real>[\d\.]+) secs\] *$/)
    if post_times
      post_times.names.each {|name|
        record[name] = adjust_type(post_times[name])
      }    
    end
    body = $` || m[:body]

    case body
    when /^\[GC.+ParNew: (?<new_before>\d+)K-\>(?<new_after>\d+)K\((?<new_total>\d+)K\), (?<new_gctime>[\d\.]+) secs\] (?<heap_before>\d+)K\-\>(?<heap_after>\d+)K\((?<heap_total>\d+)K\)( icms_dc=(?<icms_dc>\d+) )?, (?<gctime>[\d\.]+) secs\]/
      m = Regexp.last_match
      record["type"] = "YoungGC"
    when /^\[GC \[1 CMS-initial-mark: (?<old_before>\d+)K\((?<old_threshold>\d+)K\)\] (?<heap_before>\d+)K\((?<heap_total>\d+)K\), (?<gctime>[\d\.]+) secs\]/
      m = Regexp.last_match
      record["type"] = "CMS-initial-mark"
    when /^\[GC\[YG occupancy: (?<new_before>\d+) K \((?<new_threshold>\d+) K\)\].+\[1 CMS-remark: (?<old_before>\d+)K\((?<old_threshold>\d+)K\)\] (?<heap_before>\d+)K\((?<heap_total>\d+)K\), (?<gctime>[\d\.]+) secs\]/
      m = Regexp.last_match
      record["type"] = "CMS-parallel-remark"
    when /\[Full GC.+\(concurrent mode failure\).+ (?<gctime>[\d\.]+) secs\]/
      m = Regexp.last_match
      record["type"] = "FullGC-CMS-failure"
    when /\[Full GC.+ (?<gctime>[\d\.]+) secs\]/
      m = Regexp.last_match
      record["type"] = "FullGC"
    when /^\[(?<type>[A-Za-z\-]+)(: (?<time_cpu>[\d\.]+)\/(?<time_wall>[\d\.]+) secs)?\]/
      m = Regexp.last_match
    end
    
    if m == nil
      record["unknown"] = body
    else
      m.names.each {|name|
        if name == "type"
          record[name] = m[name]
        elsif m[name]
          record[name] = adjust_type(m[name])
        end
      }    
    end
    return record
  end
end
