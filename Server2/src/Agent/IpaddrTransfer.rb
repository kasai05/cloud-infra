# ファイル名：ipaddrTransfer.rb
# 概要：IPアドレス変換
# 役割：IPアドレスの記述方法を変換する
# 実行方法：メインプログラムから各メソッドを直接呼び出す
# バージョン：2.0
# 作成者：黒木

module IpaddrTransfer
	def deletePadding(ipaddr)
		one = ipaddr[0..2]
		two = ipaddr[4..6]
		three = ipaddr[8..10]
		four = ipaddr[12..15]
		ans = ""

		ary = Array[one,two,three,four]
		ary.each do |mm|
			if mm == "000" then
				mm = "0"
			else
				3.times{
					if mm[0] == "0" then
						mm.slice!(0)
					end
				}
			end
			ans += mm + "."
		end
		ans.slice!(-1)

		return ans
	end

	module_function :deletePadding

end


