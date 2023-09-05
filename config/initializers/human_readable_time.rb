def human_readable_time(secs)
  [[60, :seconds], [60, :minutes], [24, :hours], [Float::INFINITY, :days]].map do |count, name|
    next unless secs > 0

    secs, number = secs.divmod(count)
    "#{number.to_i} #{(number == 1) ? name.to_s.delete_suffix("s") : name}" unless number.to_i == 0
  end.compact.reverse.join(", ")
end