# ファイル名：MetaCreater.rb
# 概要：メタディスク作成モジュール
# 役割：メタディスクの作成を行う
# 実行方法：メインプログラムから直接呼び出す
# バージョン：2.0
# 作成者：黒木


module MetaCreater
	def create(uuid, ipaddr, pubkey, hostname)
		begin
			#ディレクトリを作成する
			puts "prepare directory"
			cmd = "mkdir -p /var/kvm/meta/#{uuid}"
				%x[#{cmd}]

			#ディスク領域を確保する
			puts "prepare space of disk"
			cmd = "truncate -s 10m /var/kvm/meta/#{uuid}/metadata_drive"
				%x[#{cmd}]
			cmd = "sync"
			%x[#{cmd}]

			#パーティションファイルを読み込む
			puts "read partition file"
			cmd = "parted /var/kvm/meta/#{uuid}/metadata_drive < /var/kvm/meta/parted_procedure.txt "
				%x[#{cmd}]

			#ループバックにマウントする
			puts "mount loopback"
			cmd = "kpartx -av /var/kvm/meta/#{uuid}/metadata_drive | awk '{print $3}'"
				devNo = %x[#{cmd}].chomp

			#処理待ちする
			puts "settle..."
			cmd = "udevadm settle"
			%x[#{cmd}]

			#ラベルをつけてフォーマットする
			puts "format with label"
			cmd = "mkfs -t vfat -n METADATA /dev/mapper/#{devNo}"
				%x[#{cmd}]

			#マウント先フォルダを作成
			puts "make directory for mount"
			cmd = "mkdir /var/kvm/meta/#{uuid}/md_mount"
				%x[#{cmd}]

			#マウントを行う
			puts "mount"
			cmd = "mount -t vfat /dev/mapper/#{devNo} /var/kvm/meta/#{uuid}/md_mount"
				%x[#{cmd}]

			#ファイルにデータを書き込む
			puts "write file"
			cmd = "echo 'uuid #{uuid}' > /var/kvm/meta/#{uuid}/md_mount/metadata"
				%x[#{cmd}]
			cmd = "echo 'ipaddr #{ipaddr}' > /var/kvm/meta/#{uuid}/md_mount/metadata"
			%x[#{cmd}]
			cmd = "echo 'hostname #{hostname}' > /var/kvm/meta/#{uuid}/md_mount/metadata"
			%x[#{cmd}]
			cmd = "echo 'pubkey #{pubkey}' >> /var/kvm/meta/#{uuid}/md_mount/metadata"
			%x[#{cmd}]

			#アンマウント
			puts "umount"
			cmd = "umount /var/kvm/meta/#{uuid}/md_mount"
				%x[#{cmd}]

			puts "done"
			return devNo

		rescue
			puts "error occured : " + cmd
		end
	end

	module_function :create

end
