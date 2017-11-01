require "./Diskchecker.rb"

puts diskcheck(500000000)
kvm = diskcheck(500000000)
Hash.new([])
puts kvm[:hostname]
puts kvm[:disk]
