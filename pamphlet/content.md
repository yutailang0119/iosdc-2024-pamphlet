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

　本稿の全文、GitHubリポジトリ`/pamphlet`以下は、クリエイティブ・コモンズの[CC-BY 4.0](https://creativecommons.org/licenses/by/4.0/deed.ja)で管理します。
　サンプルコード、GitHubリポジトリ`/ExampleApp`以下は、MITライセンスで管理します。

## ローカルネットワークのプライバシー

　本稿で扱うローカルネットワークアクセスは、Info.plistでユーザーの許可が必要です。
ローカルネットワークの使用には、[NSLocalNetworkUsageDescription](https://developer.apple.com/documentation/bundleresources/information_property_list/nslocalnetworkusagedescription)に用途を記載します。
Bonjourでの検出には、[NSBonjourServices](https://developer.apple.com/documentation/bundleresources/information_property_list/nsbonjourservices)にサービスタイプを宣言します。
詳しくはWWDC20の動画[Support local network privacy in your app](https://developer.apple.com/videos/play/wwdc2020/10110/)を参照してください。

　また、iPhoneやMacのネットワーク設定によって、ローカルネットワークの通信は制限されることがあります。
一時的にFirewallの設定を見直してください。

# Network.frameworkの概観

　Network.frameworkは、データ送受信のためのネットワーク接続用フレームワークです。
URLSessionの内部でも使用されており、多くのアプリを支えています。

## サポートする通信プロトコル

　Network.frameworkを使用することで、TLS、TCP、UDPなどの主要な通信プロトコルに直接アクセスが可能です。
TCPは[NWProtocolTLS](https://developer.apple.com/documentation/network/nwprotocoltls)といった、プロトコルに対応するclassがそれぞれ用意されています。
iOS 13では[NWProtocolWebSocket](https://developer.apple.com/documentation/network/nwprotocolwebsocket)でWebSocket、iOS 15では[NWProtocolQUIC](https://developer.apple.com/documentation/network/nwprotocoludp)でQUICのサポートが追加されました。

　さらに[NWProtocolFramer](https://developer.apple.com/documentation/network/nwprotocolframer)を使って、独自プロトコルでの通信も実装できます。
従来のソケット通信の複雑なバイト列を扱うことなく、構造化されたメッセージの読み取りが可能です。
詳しくはWWDC19の動画[Advances in Networking, Part 2](https://developer.apple.com/videos/play/wwdc2019/713/)を参照してください。

## NWPathMonitorで通信状態を監視

　Network.frameworkの機能の一つは、ネットワーク状況の監視です。
監視には[`NWPathMonitor`](https://developer.apple.com/documentation/network/nwpathmonitor)を使用します。
具体的な使用方法は、サンプルコードを参照してください。

　`NWPathMonitor`は、実際に通信が成功するかを正確に反映するものではないことに注意します。
ユーザーによって行われた通信の場合、常に接続を試みるべきです。
ネットワークサービスが利用可能かを推測したり、その判断をキャッシュしたりしないでください。

## Network.frameworkの登場以前

　Network.frameworkの機能は、[CFNetwork.framework](https://developer.apple.com/documentation/cfnetwork)や
[Foundation.framework](https://developer.apple.com/documentation/foundation)のNS prefixなAPIなどを駆使して、実装可能ではありました。
これらは、C言語との相互運用やポインタを意識した実装が必要で、Swiftに慣れ親しんだ開発者には難解です。
Network.frameworkの利点は、単純あ接続の確立、データ転送の最適化、組込みのセキュリティ、シームレスなモビリティ、そしてSwiftのフレームワークであることです。

# Bonjourを用いたネットワーク上のサービスの検出

　ネットワークはインターネットに接続するだけではありません。
ローカルネットワーク上のほかのデバイスとやりとりすることがあります。
Appleデバイスでローカルネットワークを利用するには、Bonjour（ボンジュール）が最適です。

　Network.frameworkを使ったBonjourサービスの検出について解説します。

## Bonjour

　Bonjourは、Appleが開発したゼロ・コンフィギュレーション技術で、IPアドレスやホスト名を入力せずに接続する方法を提供します。
ビデオやオーディオのストリーミング、peer-to-peerゲーム、プリンター、カメラ、ホームデバイスとの通信の基盤となります。
たとえば、同じネットワーク上のAirPrintのプリンター自動検出やHomeKitへの接続に使用されます。

　現在ではAppleデバイスに限らず、WindowsやLinuxなどの主要プラットフォームがサポートしています。

## Network.frameworkを用いたAirPlayの検出

　Appleデバイスに囲まれた生活を送る私たちの周りには、Apple TVなどのAirPlay対応デバイスが溢れています。
Network.frameworkを使って、同じネットワーク上のAirPlayを検出してみます。

### AirPlay

　Bonjourの検出には、告知（アドバタイズ）しているサービス名を指定します。
AirPlayは、`_airplay._tcp`でTCPサービスを告知しています。
より詳しい解説は[AppleデバイスでAirPlayを使用する](https://support.apple.com/ja-jp/guide/deployment/dep9151c4ace/web)を参照してください。

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
