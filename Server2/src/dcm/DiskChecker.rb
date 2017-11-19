######################################################
#
# dcmのプログラム By Haneda
# ディスク容量を取得して、最も容量が多いサーバーを回答する
# 実際の処理は[dcm.rb]にて行う 
# Ver 2.0
# 
#######################################################

def diskcheck(diskmin)

  serve1 = `sshpass -p jiro ssh taro@192.168.0.101 df -BG | grep /$ | awk '{ print \$4 }'`
  serve3 = `sshpass -p jiro ssh taro@192.168.0.103 df -BG | grep /$ | awk '{ print \$4 }'`
  serve4 = `sshpass -p jiro ssh taro@192.168.0.104 df -BG | grep /$ | awk '{ print \$4 }'`

  x = serve1.to_i
puts x
  y = serve3.to_i
puts y
  z = serve4.to_i
puts z
  max = x
  max = y  if (y > max)
  max = z  if (z > max)
  result = max

  if (diskmin.to_i + 5 ) < result 
     if result == x then
         kvm_1 = {:hostname => "Server1" , :disk => x}
         puts kvm_1 
	 return kvm_1
     elsif result == y then
         kvm_3 = {:hostname => "Server3" ,:disk => y}
         puts kvm_3
	 return kvm_3
     else  result == z
         kvm_4 = {:hostname => "Server4" ,:disk => z}
         puts kvm_4
	 return kvm_4
     end
  else
    kvm_res  = {:hostname => "ERROR" ,:disk => "ERROR"}
    return kvm_res 
  end
end

