#######################
# ファイル名：StatusCheck.rb
# 概要：VM情報取得API
# 役割：ユーザーIDに紐づくVM情報を取得する
# 実行方法：guiでの画面、curlコマンド
# バージョン：2.0
# 作成者：yosuke.kasai

require 'json'
require 'grape'
require 'mysql2'
require 'grape-entity'

require_relative '../model/virtual_machine.rb'

module API
  module Entity
    class VirtualMachine < Grape::Entity
      expose :userid
      expose :status
      expose :hostname
      expose :externalport
      expose :cpu
      expose :memory
      expose :disk
    end
  end

  class StatusCheck < Grape::API
    resource :status do
      # 入力項目のバリデーション
      params do
        requires :userid, type: String, allow_blank: false
      end
      get '/:userid' do
        # st = Status.all
        status = virtual_machines.find(userid: params[:userid])
        present st, with: API::Entity::VirtualMachine
      end
    end
  end
end
