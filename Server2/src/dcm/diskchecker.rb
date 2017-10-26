######################################################
#
#dcmのプログラム By Haneda
# 実際の処理は[dcm.rb]にて行う 
# Ver 0.1
# 
#######################################################
#
#require './dcm.rb'

def max3(x, y, z)
    max = x
    max = y  if (y > max)
    max = z  if (z > max)

    return max
end

  serve1 = `sshpass -p jiro ssh taro@192.168.0.101 df | grep /$ | awk '{ print \$4 }'`
  serve3 = `sshpass -p jiro ssh taro@192.168.0.103 df | grep /$ | awk '{ print \$4 }'`
  serve4 = `sshpass -p jiro ssh taro@192.168.0.104 df | grep /$ | awk '{ print \$4 }'`

  result = max3(serve1,serve3,serve4)

   if result == serve1 then
     puts "Server1"
   elsif result == serve3 then
     puts "Server3"
   else  result == serve4
     puts "Server4"
   end

#debug用
  #puts serve1,serve3,serve4  
  #puts result
