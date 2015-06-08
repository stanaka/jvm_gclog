require 'time'

class JVMGCLog
  def initialize
    @regexp_prefix = Regexp.compile('^(?<time>\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d+\+\d{4}): (?<uptime>\d+\.\d*): ')
  end
  
  def adjust_type(value)
    if value =~ /^\d+\.\d+$/
      return value.to_f
    elsif value =~ /^\d+$/
      return value.to_i
    end
    value
  end

  def match_fields_to_hash(m)
    record = {}
    if m == nil
      return nil
    else
      m.names.each {|name|
        record[name] = adjust_type(m[name])
      }    
    end
    record
  end
  
  def recognize_chunks(lines)
    chunks = []

    line = lines.shift
    while line
      chunk = []

      if line != nil && @regexp_prefix.match(line)
        chunk << line.strip
        line = lines.shift
      end

      details = []
      while line != nil && !@regexp_prefix.match(line)
        chunk << line.strip
        line = lines.shift
      end

      chunks << chunk
    end

    chunks
  end

  def parse_chunks(chunks)
    res = []
    while (chunk = chunks.shift) != nil
      res.push parse(chunk)
    end
    res.compact
  end

  def parse(data)
    if data.class == String
      data = [data]
    end
    record = {}
    m = @regexp_prefix.match(data[0])
    body = $'

    record["time"] = Time.parse(m[:time]).to_i
    record["uptime"] = adjust_type(m["uptime"])

    case body
    when /^\[GC pause/
      line = data.join(" ")
      fields = [
        /\[GC Worker Total \(ms\):  (?<gctime_total>\d+\.\d+)/,
        /\[Eden: (?<eden_before>\d+\.\d+.)\((?<eden_total_before>\d+\.\d+.)\)->(?<eden_after>\d+\.\d+.)\((?<eden_total_after>\d+\.\d+.)\) Survivors: (?<survivors_before>\d+\.\d+.)->(?<survivors_after>\d+\.\d+.) Heap: (?<heap_before>\d+\.\d+.)\((?<heap_total_before>\d+\.\d+.)\)->(?<heap_after>\d+\.\d+.)\((?<heap_total_after>\d+\.\d+.)\)\]/,
        /\[Times: user=(?<gctime_user>[\d\.]+) sys=(?<gctime_sys>[\d\.]+), real=(?<gctime_real>[\d\.]+) secs\]/
      ]
      fields.each { |f|
        fields_match = f.match(line)
        fields_match.names.each {|name|
          record[name] = adjust_type(fields_match[name])
        }
      }
      record["type"] = "G1GC"
      return record

    when /^Total time for which application threads were stopped/
      # ignore this kind of line.
      return nil

    when /^\[GC.+ParNew: (?<new_before>\d+)K-\>(?<new_after>\d+)K\((?<new_total>\d+)K\), (?<new_gctime>[\d\.]+) secs\] (?<heap_before>\d+)K\-\>(?<heap_after>\d+)K\((?<heap_total>\d+)K\)( icms_dc=(?<icms_dc>\d+) )?, (?<gctime>[\d\.]+) secs\]/
      m = Regexp.last_match
      record.update(match_fields_to_hash(m))
      record["type"] = "YoungGC"

    when /^\[GC \[1 CMS-initial-mark: (?<old_before>\d+)K\((?<old_threshold>\d+)K\)\] (?<heap_before>\d+)K\((?<heap_total>\d+)K\), (?<gctime>[\d\.]+) secs\]/
      m = Regexp.last_match
      record.update(match_fields_to_hash(m))
      record["type"] = "CMS-initial-mark"

    when /^\[GC\[YG occupancy: (?<new_before>\d+) K \((?<new_threshold>\d+) K\)\].+\[1 CMS-remark: (?<old_before>\d+)K\((?<old_threshold>\d+)K\)\] (?<heap_before>\d+)K\((?<heap_total>\d+)K\), (?<gctime>[\d\.]+) secs\]/
      m = Regexp.last_match
      record.update(match_fields_to_hash(m))
      record["type"] = "CMS-parallel-remark"

    when /\[Full GC.+\(concurrent mode failure\).+ (?<gctime>[\d\.]+) secs\]/
      m = Regexp.last_match
      record.update(match_fields_to_hash(m))
      record["type"] = "FullGC-CMS-failure"

    when /\[Full GC.+ (?<gctime>[\d\.]+) secs\]/
      m = Regexp.last_match
      record.update(match_fields_to_hash(m))
      record["type"] = "FullGC"

    when /^\[(?<type>[A-Za-z\-]+)(: (?<time_cpu>[\d\.]+)\/(?<time_wall>[\d\.]+) secs)?\]/
      m = Regexp.last_match
      record.update(match_fields_to_hash(m))

    else
      record["type"] = "Unknown"
      record["unknown"] = body
    end

    if m = $'.match('\[Times: user=(?<gctime_user>[\d\.]+) sys=(?<gctime_sys>[\d\.]+), real=(?<gctime_real>[\d\.]+) secs\]')
      record.update(match_fields_to_hash(m))
    end

    return record
  end
end
