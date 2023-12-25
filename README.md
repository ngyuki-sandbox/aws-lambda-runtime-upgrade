# aws-lambda-runtime-upgrade

素のままで '$LATEST' を参照していると Lambda のコードとランタイムを同時に更新してもタイムラグがあるため更新時に数回エラーになります。

```sh
git sw v16
terraform apply -auto-approve

while :; do aws lambda invoke --function-name lambda-runtime-upgrade --log-type Tail /dev/null | jq .LogResult -r | base64 -d; done

git sw v20
terraform apply -auto-approve
```

別々のエイリアスを設けて参照元で切り替えれば新旧混在可能です。

```sh
git sw v16
terraform apply -auto-approve

while :; do aws lambda invoke --function-name lambda-runtime-upgrade:nodejs16 --log-type Tail /dev/null | jq .LogResult -r | base64 -d; done

git sw v20
terraform state rm aws_lambda_alias.main

terraform apply -auto-approve

aws lambda invoke --function-name lambda-runtime-upgrade:nodejs20 --log-type Tail /dev/null | jq .LogResult -r | base64 -d
aws lambda invoke --function-name lambda-runtime-upgrade --log-type Tail /dev/null | jq .LogResult -r | base64 -d
```

もしくは、コードとランタイムがアトミックに切り替われば良いだけなので、参照元は固定のエイリアスを参照しつつ、エイリアスのバージョンを更新するのでも OK です。

```sh
git sw v16
terraform apply -auto-approve

while :; do aws lambda invoke --function-name lambda-runtime-upgrade:stable --log-type Tail /dev/null | jq .LogResult -r | base64 -d; done

git sw v20
terraform apply -auto-approve
```
