def convert_v8(value)
  if value.is_a?(V8::Array)
    result = []
    value.each do |val|
      result << convert_v8(val)
    end
  elsif value.is_a?(V8::Object)
    result = {}
    value.each do |key|
      result[key] = convert_v8(value[key])
    end
  else
    result = value
  end
  result
end