module Type
  # VM作成
  CREATE = "create"
  # VM起動
  START = "start"
  # VM停止
  STOP = "stop"
  # VM強制停止
  DESTROY = "destroy"
  # VM削除
  DElETE = "delete"

  # 処理タイプの一覧を返す
  def self.all
    self.constants.map{|name| self.const_get(name) }
  end
end
