以下サイトの運営を想定

- EC2インスタンス上でWebサーバを起動している
- 同インスタンス上にLet’s Encryptのcertbotをインストールしており、証明書の取得更新も同インスタンス上で実施

課題

- Let’s Encryptがチャレンジレスポンス認証のため、90日ごとの証明書更新のたびに以下作業が必要
  - 80ポートを解放
  - certbotの証明書更新コマンドを実行
  - 80ポートを閉じる
- 手運用だとミスが起きうる＆80ポート解放時間が長くなる
- サイト数が増えればより、、、

ALBとACMを用意すれば済む話だがそれすらコスト的に出来ないサイトのため