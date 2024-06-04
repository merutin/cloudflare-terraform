## Cloudflare - terraform
cloudflareのリソースをterraformで作成するための検証用リポジトリです。

検証している内容は以下の通り

- dnssecの作成
- dnsの設定
  - 複数のURL検証
- proxiedをONに設定
  - ONの場合はttlを1にする必要がある
- Aレコード、TXTレコードの作成
- 複数のIPアドレスの展開

```
terraform plan -var-file sample.tfvars
```