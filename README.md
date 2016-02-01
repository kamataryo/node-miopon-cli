# node-miopon-cli

[<img src="icon/icon.png" width="60" alt="アイコン">](https://www.npmjs.com/package/node-miopon-cli
)

[![Build Status](https://travis-ci.org/KamataRyo/node-miopon-cli.svg?branch=master)](https://travis-ci.org/KamataRyo/node-miopon-cli)
[![npm version](https://badge.fury.io/js/node-miopon-cli.svg)](https://badge.fury.io/js/node-miopon-cli)
[![Dependency Status](https://david-dm.org/kamataryo/node-miopon-cli.svg)](https://david-dm.org/kamataryo/node-miopon-cli)
[![devDependency Status](https://david-dm.org/kamataryo/node-miopon-cli/dev-status.svg)](https://david-dm.org/kamataryo/node-miopon-cli#info=devDependencies)

[IIJmioクーポンスイッチAPI](https://www.iijmio.jp/hdd/coupon/mioponapi.jsp)のCLIツールです。

## install
`npm install -g node-miopon-cli`

## 注意
ホームフォルダ下に、設定ファイル.node-mioponファイルを生成します。

## Interfaces

### 設定ファイル作成
`mio init`

※ デベロッパーIDとリダイレクトURIは、公式サイトに従って登録してください。
[IIJmioクーポンスイッチAPIのご利用に当たって(IIJmioのサイト)](https://www.iijmio.jp/hdd/coupon/mioponapi.jsp#goriyou)

### アクセストークンと回線情報を取得
`mio auth`

### トークンの期限切れ確認
`mio info` or `mio status`

### トークンのon, off
`mio on` and `min off`

※現在のバージョンでは、すべての回線をon/offします

### トークンを含む設定ファイルを削除
`mio delete` or `mio del` or `mio d`
