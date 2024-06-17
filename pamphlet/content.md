□Bonjourとネットワーク通信を通して学ぶNetwork.framework実践ガイド
https://fortee.jp/iosdc-japan-2024/proposal/38a4ff87-2cc1-4494-b8e6-63fcf506430f

　[Network.framework](https://developer.apple.com/documentation/network)は、2018年6月の「World Wide Developers Conference 2018」（以下、WWDC18）で発表されました。
このフレームワークは、iOS 12.0をはじめとしたWWDC18発表のAppleプラットフォームで使用できます。
また、visionOSもサポートしています。

　本稿ではNetwork.frameworkを活用し、NWBrowserでのネットワークサービスの検出と、NWListenerおよびNWConnectionを用いた通信について解説します。
また、Swift Concurrencyと組み合わせて、2024年段階のアプローチでサンプルコードを提供します。
Network.frameworkがサポートする範囲は膨大で、すべてを網羅はできませんが、取り組むきっかけとなる内容を扱います。

# はじめに

　本稿を読む上での注意事項を説明します。

## GitHubリポジトリ

　本稿は[yutailang0119/iosdc-2024-pamphlet](https://github.com/yutailang0119/iosdc-2024-pamphlet)でも閲覧可能です。
サンプルコードの全体は、リポジトリの`/ExampleApp.xcworkspace`を開き、参照してください。

　内容に訂正がある場合、GitHubリポジトリで訂正します。
また、質問などは[issues](https://github.com/yutailang0119/iosdc-2024-pamphlet/issues)から連絡ください。

## 開発環境

　本稿の内容は、開発環境としてmacOS Sonoma 14.5（23F79）とXcode 15.4（15F31d）を使用して動作を確認しています。
開発言語にはXcodeに付属のSwift 5.10を利用します。
サンプルコードの実行は、iOS 17.5（21F79）を対象とします。

## 権利・ライセンス
## ローカルネットワークのプライバシー

# Network.frameworkの概観
## サポートする通信プロトコル
## NWPathMonitorで通信状態を監視
## Network.frameworkの登場以前

# Bonjourを用いたネットワーク上のサービスの検出
## Bonjour
## Network.frameworkを用いたAirPlayの検出
### AirPlay
### NWBrowserでのAirPlay検出

# Network.frameworkでのUDP送受信
## Bonjourサービスの告知（アドバタイズ） ── NWListener
## Bonjourサービスの検出（ディスカバー） ── NWBrowser
## コネクションの確立 ── NWConnection
### Bonjourサービス検出側のコネクション
### Bonjourサービス告知側のコネクション
## データの送受信
### 送信側の実装
### 受信側の実装

# まとめ
