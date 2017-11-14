require_relative 'message_queue.rb'
require_relative 'status_check.rb'

module API
  class Base < Grape::API
    # apiアクセスに接頭辞を付与する
    prefix :api
    # 出力フォーマットの設定
    format :json

    # Grapeの例外の場合は400を返す
    rescue_from Grape::Exceptions::Base do |e|
      error!(e.message, 400)
    end

    # それ以外は500
    rescue_from :all do |e|
      error!({error: e.message, backtrace: e.backtrace[0]}, 500)
    end

    mount API::MessageQueue
    mount API::StatusCheck
  end
end
