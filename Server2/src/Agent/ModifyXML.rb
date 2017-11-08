# ファイル名：ModifyXML.rb
# 概要：XML操作用モジュール
# 役割：VirtualMachine定義ファイルの内容を変更する
# 実行方法：メインプログラムからインスタンス化して使用する
# バージョン：2.0
# 作成者：黒木


require 'rexml/document'

class ModifyXML
	def initialize(xmlFile, newFile)
		@file = File.open(xmlFile)
		@newFile = newFile
		@doc = REXML::Document.new(@file)
	end
	
	def setName(newName)
		element = @doc.elements['domain/name']
		element.text = newName
		File.write(@newFile, @doc)
	end
	
	def setUuid(newUuid)
		element = @doc.elements['domain/uuid']
		element.text = newUuid
		File.write(@newFile, @doc)
	end

	def setVcpu(newVcpu)
		element = @doc.elements['domain/vcpu']
		element.text = newVcpu
		File.write(@newFile, @doc)
	end

	def setMemory(newMemory)
		element = @doc.elements['domain/memory']
		element.text = newMemory.to_i * 1024
		File.write(@newFile, @doc)
	end

	def setMacAddress(newMacAddress)
		element = @doc.elements['domain/devices/interface/mac']
		element.attributes['address'] = newMacAddress
		File.write(@newFile, @doc)
	end

	def setDiskSource(newDiskSource)
		element = @doc.elements['domain/devices/disk[1]/source']
		element.attributes['file'] = newDiskSource
		File.write(@newFile, @doc)
	end

	def setMetaDisk(deviceID)
		element = @doc.elements['domain/devices/disk[2]/source']
		element.attributes['file'] = "/dev/mapper/" + deviceID.to_s
		File.write(@newFile, @doc)
	end

end

