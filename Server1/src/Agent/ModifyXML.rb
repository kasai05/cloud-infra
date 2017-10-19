#########################################################
# 
# XMLファイルの内容を書き換えるプログラム By Kuroki
# Ver 1.0
#
#########################################################

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
		element = @doc.elements['domain/devices/disk/source']
		element.attributes['file'] = newDiskSource
		File.write(@newFile, @doc)
	end
end

