# ファイル名：VmController.rb
# 概要：VirtualMachine操作用モジュール
# 役割：VirtualMachineを作成/起動/停止/強制停止/削除する
# 実行方法：メインプログラムから各メソッドを直接呼び出す
# バージョン：2.0
# 作成者：黒木

require 'json'  # json形式とhash形式を相互に変換するライブラリ
require 'fileutils'  # ファイルコピーなどの処理を行うライブラリ
require './ModifyXML.rb'  # VirtualMachine定義ファイル(XML)の内容を変更するクラス
require './MetaCreater.rb'  # メタドライブの作成、内容書き込みを行うモジュール
require './IpaddrTransfer.rb'  # IPアドレスの0パディングを消去するモジュール

module VmController
	# 定数の設定
	ORIGINALXML = "/var/kvm/xml/original.xml"  # オリジナルとなるXMLファイル
	NEWXMLPATH = "/var/kvm/xml/"               # 新しいXMLファイルを作成するパス
	ORIGINALDISK = "/var/kvm/disk/original"    # オリジナルとなるデータディスク(仮想マシンのHDD)
	NEWDISKPATH = "/var/kvm/disk/"             # 新しいデータディスクを作成するパス

	# VirtualMachineを作成するメソッド
	def vmCreate(hash)
		begin
			puts "$$$$$ vmの作成開始 $$$$$"

			puts "***** メタディスクの作成開始 *****"
			ipaddr = IpaddrTransfer.deletePadding(hash["ipaddr"])  # 192.168.000.001のような形式だとエラーになるので192.168.0.1の形式に変換する
			devID = MetaCreater.create(hash["uuid"], ipaddr, hash["publickey"], hash["hostname"])  # メタディスクを作成し、デバイスIDを取得する
			puts "***** メタディスクの作成完了 *****"

			puts "***** XML作成開始 *****"
			newXML = NEWXMLPATH + hash["uuid"] + ".xml"  # 新しいXMLファイルのフルパスを設定
			xml = ModifyXML.new(ORIGINALXML, newXML)  # 新しいXMLファイルを作成
			disksource = NEWDISKPATH + hash["uuid"]  # 新しいデータディスクのフルパスを設定
			xml.setName(hash["uuid"])  # xmlで定義する名称をキューメッセージから取得した値(=DataBaseから持って来た値)にする
			xml.setUuid(hash["uuid"])  # xmlで定義するuuidをキューメッセージから取得した値にする
			xml.setVcpu(hash["vcpu"])  # 仮想cpuの数をXMLに記載
			xml.setMemory(hash["memory"])  # 仮想メモリのサイズをXMLに記載
			xml.setDiskSource(disksource)  # データディスクのフルパスをXMLに記載
			xml.setMetaDisk(devID)  # メタディスクのデバイスIDをXMLに記載
			xml.setMacAddress(hash["macaddr"])  # macアドレスをXMLに記載
			puts "***** XML作成完了 *****"

			#オリジナルディスクからデータをコピーする
			puts "***** ディスクデータコピー開始 *****"
			newDisk = NEWDISKPATH + hash["uuid"]
			FileUtils.cp(ORIGINALDISK, newDisk)
			puts "***** ディスクデータコピー完了 *****"

			#定義ファイルを読み込み
			puts "***** 定義ファイル読み込み開始 *****"
			%x[ #{"virsh define " +  newXML} ]
			puts "***** 定義ファイル読み込み完了 *****"
			puts "***** vmの作成完了 *****"

			return "created"
		rescue => error
			puts error
			return "error_create"
		end

	end

	# VirtualMachineを起動するメソッド
	def vmStart(hash)
		begin
			puts "***** vmを起動します。対象uuid : #{hash["uuid"]} *****"
				target = hash["uuid"]
			value = %x[ #{"virsh start " + target }]
			puts "***** vmを起動しました。対象uuid : #{hash["uuid"]} *****"
			return "started"
		rescue => error
			puts error
			return "error_start"
		end
	end

	# VirtualMachineを停止するメソッド
	def vmStop(hash)
		begin
			puts "***** vmを停止します。対象uuid : #{hash["uuid"]} *****"
				target = hash["uuid"]
			value = %x[ #{"virsh shutdown " + target } ]
			puts "***** vmを停止しました。対象uuid : #{hash["uuid"]} *****"
			return "stopped"
		rescue => error
			puts error
			return "error_stop"
		end
	end

	# VirtualMachineを強制停止するメソッド
	def vmDestroy(hash)
		begin
			puts "***** vmを強制停止します。対象uuid : #{hash["uuid"]} *****"
				target = hash["uuid"]
			value = %x[ #{"virsh destroy " + target } ]
			puts "***** vmを強制停止しました。対象uuid : #{hash["uuid"]} *****"
			return "destroyed"
		rescue => error
			puts error
			return "error_destroy"
		end
	end

	# VirtualMachineを削除するメソッド
	def vmDelete(hash)
		begin
			puts "***** vmを削除します。対象uuid : #{hash["uuid"]} *****"
				target = hash["uuid"]
			self.vmDestroy(hash)  # 削除前に強制停止を行う
			value = %x[ #{"virsh undefine " + target } ]
			targetDisk = NEWDISKPATH + hash["uuid"]
			File.delete targetDisk
			targetFile = NEWXMLPATH + hash["uuid"] + ".xml"
			File.delete targetFile
			puts "***** vmを削除しました。対象uuid : #{hash["uuid"]} *****"
				return "deleted"
		rescue => error
			puts error
			return "error_delete"
		end
	end

	module_function :vmCreate, :vmStart, :vmStop, :vmDestroy, :vmDelete
end
