□Bonjourとネットワーク通信を通して学ぶNetwork.framework実践ガイド

# はじめに
## GitHubリポジトリ
## 開発環境
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
