#!/bin/bash
set -e
# Rails特有の問題を解決するためのコマンド
rm -f /my_app/tmp/pids/server.pid

# production環境の場合のみJSとCSSをビルド
if [ "$RAILS_ENV" = "production" ]; then
  bundle exec rails assets:clobber
  bundle exec rails assets:precompile
fi

# サーバー実行(DockerfileのCMDをセット)
exec "$@"