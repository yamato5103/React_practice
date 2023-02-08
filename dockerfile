FROM ruby:3.1.2

# railsコンソール中で日本語入力するための設定
ENV LANG=C.UTF-8

# 本番環境用のRAILS_ENV設定
ENV RAILS_ENV=production
# bundlerのバージョンを固定するための設定
ENV BUNDLER_VERSION=2.3.10

# インストール可能なパッケージ一覧の更新
RUN apt-get update -qq \
  # パッケージのインストール（-yは全部yesにするオプション）
  # コンパイラに必要なパッケージ、PostgreSQLのクライアント
  # PostgreSQLの接続に必要なパッケージをインストール
  # chromium-driverはRSpecのシステムスペック用に必要
  # credentials.yml.encの編集用にvimが必要
  && apt-get install build-essential \
  postgresql-client \
  libpq-dev \
  chromium-driver \
  -y vim-gtk \
  -y nodejs \
  npm \
  yarn\
  # キャッシュを削除して容量を小さくする
  && rm -rf /var/lib/apt/lists/*

# 作業ディレクトリの指定
RUN mkdir /my_app
WORKDIR /my_app

# ローカルにあるGemfileとGemfile.lockを
# コンテナ内のディレクトリにコピー
COPY Gemfile /my_app/Gemfile
COPY Gemfile.lock /my_app/Gemfile.lock

# bundlerのバージョンを固定する
RUN gem install bundler -v $BUNDLER_VERSION
RUN bundle -v

# bunlde installを実行する
RUN bundle install --jobs=4
COPY . /my_app

# コンテナ起動時に実行するスクリプト
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]