######################################################
#
#dcmのプログラム By Haneda
# 実際の処理は[dcm.rb]にて行う 
# Ver 0.1
# 
#######################################################
#
#require './dcm.rb'

#def diskcheck

  serve1 = `sshpass -p jiro ssh taro@192.168.0.101 df | grep /$ | awk '{ print \$4 }'`
  serve3 = `sshpass -p jiro ssh taro@192.168.0.103 df | grep /$ | awk '{ print \$4 }'`
  serve4 = `sshpass -p jiro ssh taro@192.168.0.104 df | grep /$ | awk '{ print \$4 }'`
 
  x = serve1.to_i
  y = serve3.to_i
  z = serve4.to_i
  max = x
  max = y  if (y > max)
  max = z  if (z > max)
  result = max

puts serve1,serve3,serve4  
puts x,y,z  
puts result
#puts kvm_1,kvm_3,kvm_4

   if result == x then
     kvm_1 = Hash.new()
     kvm_1 = {:Server1 => x}
     return kvm_1
   elsif result == y then
     kvm_3 = {:Server3 => y}
     return kvm_3
   else  result == z
     kvm_4 = {:Server4 => z}
     return kvm_4
   end

#end
#debug用
puts serve1,serve3,serve4  
puts x,y,z  
puts result
puts kvm_1,kvm_3,kvm_4
#diskcheck
#end

#diskcheck
