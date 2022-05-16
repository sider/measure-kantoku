# measure-kantoku
measure-kantokuはGitHub、JIRAといったソースコード管理システム、プロジェクト管理システムから情報を取得し、Elastic Stackを用いて可視化を行うシステムです。

## セットアップ
### 1. リポジトリをcloneする
```shell-session
$ git clone https://github.com/sider/measure-kantoku
```

### 2. 設定ファイルの編集
`collector_github.env.sample`にパラメータをセットし、`collector_github.env`として保存する。パラメータは以下の通り。
- `GITHUB_ACCESS_TOKEN`: GitHubアカウントの[個人アクセストークン](https://docs.github.com/ja/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)（例: `ghp_XXXX`）
- `GITHUB_TARGET_REPOSITORY_OWNER`: 可視化対象のリポジトリのオーナー名 (例: [sider](https://github.com/sider))
- `GITHUB_TARGET_REPOSITORY_NAME`: 可視化対象のリポジトリのリポジトリ名（例: [measure-kantoku](https://github.com/sider/measure-kantoku)）
- `GITHUB_MAX_ISSUE`: 取得するIssue数の上限
- `COLLECTION_INVERVAL_IN_MINUTES`: 情報収集の頻度（分単位）

### 3. 起動
```shell-session
$ docker-compose up -d
```

### 4. ブラウザでKibanaへアクセスする
`http://localhost:5601`へアクセスするとKibanaの初期画面が表示されます。Kibanaの起動には数十秒～数分かかるため、アクセスできない場合は、しばらく時間を置いて再度お試しください。

## ライセンスについて
本ソフトウェアのElastic Stack(Elasticsearch, Kibana)を除く全ての部分はMITライセンスが適用されます。Elastic Stackについては、[Elastic License 2.0](https://www.elastic.co/jp/licensing/elastic-license)が適用されます。Elastic Licenseはそれが適用されるソフトウェアを用いて第三者へサービス提供することを禁じていますので、ご留意ください。（一般的に個人、自社のプロジェクトを自分のために可視化する場合は、問題なく利用できると考えられます。）

（参考情報）
- [Elastic社によるElastic Licenseの解説記事](https://www.elastic.co/jp/blog/elastic-license-v2)

## todo
- JIRA Cloudへの対応
- etc..