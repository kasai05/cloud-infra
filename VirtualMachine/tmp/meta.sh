#!/bin/bash

#マウント
mkdir /metadata
mount LABEL=METADATA /metadata


#メタデータファイルの読み込み
ipaddr=$(cat /metadata/metadata |grep "ipaddr" | awk '{print $2}')
#pubkey=$(cat /metadata/metadata |grep "pubkey" | awk '{print $2}')
pubkey=$(cat /metadata/metadata |cut -c 8-)

#メタデータファイルの内容確認
echo $ipaddr
echo $macaddr
echo $pubkey


#IPアドレスの設定
nmcli c mod eth0 ipv4.method manual ipv4.addresses ${ipaddr}/24 ipv4.gateway 192.168.0.1
nmcli device disconnect eth0 && nmcli device connect eth0


#公開鍵の設置
mkdir /home/ikura-user/.ssh
chown ikura-user:ikura-user /home/ikura-user/.ssh
chmod 700 /home/ikura-user/.ssh
touch /home/ikura-user/.ssh/authorized_keys
chown ikura-user:ikura-user /home/ikura-user/.ssh/authorized_keys
chmod 600 /home/ikura-user/.ssh/authorized_keys
echo $pubkey >> /home/ikura-user/.ssh/authorized_keys
sync


#自分自身のスクリプトを削除する
#rm $0

#アンマウント
umount /metadata

