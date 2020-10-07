FROM node:14.4.0-alpine

# ensure local python is preferred over distribution python
ENV PATH=/usr/local/bin:$PATH

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG=C.UTF-8

# install ca-certificates so that HTTPS works consistently
# other runtime dependencies for Python are installed later

ENV GPG_KEY=0D96DF4D4110E5C43FBFB17F2D347EA6AA65421D
ENV PYTHON_VERSION=3.7.4
# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION=19.2.2
# https://github.com/pypa/get-pip
ENV PYTHON_GET_PIP_URL=https://github.com/pypa/get-pip/raw/0c72a3b4ece313faccb446a96c84770ccedc5ec5/get-pip.py
ENV PYTHON_GET_PIP_SHA256=201edc6df416da971e64cc94992d2dd24bc328bada7444f0c4f2031ae31e8dad


RUN set -ex ;\
  apk add --no-cache ca-certificates && \
  apk add --no-cache --virtual .fetch-deps \
  gnupg \
  tar \
  xz \
  \
  && wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" \
  && wget -O python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" \
  && export GNUPGHOME="$(mktemp -d)" \
  && gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY" \
  && gpg --batch --verify python.tar.xz.asc python.tar.xz \
  && { command -v gpgconf > /dev/null && gpgconf --kill all || :; } \
  && rm -rf "$GNUPGHOME" python.tar.xz.asc \
  && mkdir -p /usr/src/python \
  && tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
  && rm python.tar.xz \
  \
  && apk add --no-cache --virtual .build-deps  \
  bzip2-dev \
  coreutils \
  dpkg-dev dpkg \
  expat-dev \
  findutils \
  gcc \
  gdbm-dev \
  libc-dev \
  libffi-dev \
  libnsl-dev \
  libtirpc-dev \
  linux-headers \
  make \
  ncurses-dev \
  openssl-dev \
  pax-utils \
  readline-dev \
  sqlite-dev \
  tcl-dev \
  tk \
  tk-dev \
  util-linux-dev \
  xz-dev \
  zlib-dev \
# add build deps before removing fetch deps in case there's overlap
  && apk del .fetch-deps \
  \
  && cd /usr/src/python \
  && gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
  && ./configure \
  --build="$gnuArch" \
  --enable-loadable-sqlite-extensions \
  --enable-optimizations \
  --enable-shared \
  --with-system-expat \
  --with-system-ffi \
  --without-ensurepip \
  && make -j "$(nproc)" \
# set thread stack size to 1MB so we don't segfault before we hit sys.getrecursionlimit()
# https://github.com/alpinelinux/aports/commit/2026e1259422d4e0cf92391ca2d3844356c649d0
  EXTRA_CFLAGS="-DTHREAD_STACK_SIZE=0x100000" \
# setting PROFILE_TASK makes "--enable-optimizations" reasonable: https://bugs.python.org/issue36044 / https://github.com/docker-library/python/issues/160#issuecomment-509426916
  PROFILE_TASK='-m test.regrtest --pgo \
  test_array \
  test_base64 \
  test_binascii \
  test_binhex \
  test_binop \
  test_bytes \
  test_c_locale_coercion \
  test_class \
  test_cmath \
  test_codecs \
  test_compile \
  test_complex \
  test_csv \
  test_decimal \
  test_dict \
  test_float \
  test_fstring \
  test_hashlib \
  test_io \
  test_iter \
  test_json \
  test_long \
  test_math \
  test_memoryview \
  test_pickle \
  test_re \
  test_set \
  test_slice \
  test_struct \
  test_threading \
  test_time \
  test_traceback \
  test_unicode \
  ' \
  && make install \
  \
  && find /usr/local -type f -executable -not \( -name '*tkinter*' \) -exec scanelf --needed --nobanner --format '%n#p' '{}' ';' \
  | tr ',' '\n' \
  | sort -u \
  | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
  | xargs -rt apk add --no-cache --virtual .python-rundeps \
  && apk del .build-deps \
  \
  && find /usr/local -depth \
  \( \
  \( -type d -a \( -name test -o -name tests \) \) \
  -o \
  \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
  \) -exec rm -rf '{}' + \
  && rm -rf /usr/src/python \
  \
  && python3 --version ;\
  # make some useful symlinks that are expected to exist
  cd /usr/local/bin \
  && ln -s idle3 idle \
  && ln -s pydoc3 pydoc \
  && ln -s python3 python \
  && ln -s python3-config python-config

RUN set -ex; \
  \
  wget -O get-pip.py "$PYTHON_GET_PIP_URL"; \
  echo "$PYTHON_GET_PIP_SHA256 *get-pip.py" | sha256sum -c -; \
  \
  python get-pip.py \
  --disable-pip-version-check \
  --no-cache-dir \
  "pip==$PYTHON_PIP_VERSION" \
  ; \
  pip --version; \
  \
  find /usr/local -depth \
  \( \
  \( -type d -a \( -name test -o -name tests \) \) \
  -o \
  \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
  \) -exec rm -rf '{}' +; \
  rm -f get-pip.py ;\
  pip3 install docutils-ast-writer==0.1.2 && \
  npm install --global \
  textlint \
  textlint-rule-no-todo \
  textlint-rule-no-start-duplicated-conjunction \
  textlint-rule-prh \
  textlint-rule-max-number-of-lines \
  textlint-rule-max-comma \
  textlint-rule-no-exclamation-question-mark \
  textlint-rule-ng-word \
  textlint-rule-sjsj \
  textlint-rule-no-dead-link \
  textlint-rule-editorconfig \
  textlint-rule-report-node-types \
  textlint-rule-no-empty-section \
  textlint-rule-date-weekday-mismatch \
  textlint-rule-terminology \
  textlint-rule-period-in-list-item \
  textlint-rule-no-nfd \
  @textlint-rule/textlint-rule-no-invalid-control-character \
  textlint-rule-no-surrogate-pair \
  # textlint-rule-languagetool \
  @textlint-rule/textlint-rule-require-header-id \
  @textlint-rule/textlint-rule-no-unmatched-pair \
  textlint-rule-footnote-order \
  textlint-rule-max-doc-width \
  textlint-rule-unexpanded-acronym \
  textlint-rule-spelling \
  textlint-rule-abbr-within-parentheses \
  textlint-rule-rousseau \
  textlint-rule-alex \
  textlint-rule-common-misspellings \
  textlint-rule-ginger \
  # textlint-rule-spellchecker \
  textlint-rule-write-good \
  textlint-rule-en-max-word-count \
  textlint-rule-apostrophe \
  textlint-rule-diacritics \
  textlint-rule-stop-words \
  textlint-rule-en-capitalization \
  textlint-rule-en-spell \
  textlint-rule-max-ten \
  textlint-rule-max-kanji-continuous-len \
  textlint-rule-spellcheck-tech-word \
  textlint-rule-web-plus-db \
  textlint-rule-no-mix-dearu-desumasu \
  textlint-rule-no-doubled-joshi \
  textlint-rule-no-double-negative-ja \
  textlint-rule-no-hankaku-kana \
  textlint-rule-ja-no-weak-phrase \
  textlint-rule-ja-no-redundant-expression \
  textlint-rule-ja-no-abusage \
  textlint-rule-no-mixed-zenkaku-and-hankaku-alphabet \
  textlint-rule-sentence-length \
  textlint-rule-first-sentence-length \
  textlint-rule-no-dropping-the-ra \
  textlint-rule-no-doubled-conjunctive-particle-ga \
  textlint-rule-no-doubled-conjunction \
  textlint-rule-ja-no-mixed-period \
  textlint-rule-ja-yahoo-kousei \
  textlint-rule-max-appearence-count-of-words \
  textlint-rule-max-length-of-title \
  textlint-rule-incremental-headers \
  textlint-rule-ja-hiragana-keishikimeishi \
  textlint-rule-ja-hiragana-fukushi \
  textlint-rule-ja-hiragana-hojodoushi \
  textlint-rule-ja-unnatural-alphabet \
  @textlint-ja/textlint-rule-no-insert-dropping-sa \
  textlint-rule-prefer-tari-tari \
  @textlint-ja/textlint-rule-no-synonyms \
  textlint-rule-general-novel-style-ja \
  textlint-rule-a3rt-proofreading \
  textlint-rule-use-si-units \
  textlint-rule-joyo-kanji \
  textlint-rule-jis-charset \
  # textlint-rule-no-hoso-kinshi-yogo \
  textlint-rule-zh-half-and-full-width-bracket \
  textlint-rule-preset-ja-technical-writing \
  textlint-rule-preset-jtf-style \
  textlint-rule-preset-ja-spacing \
  textlint-rule-preset-japanese \
  textlint-rule-preset-ja-engineering-paper \
  textlint-filter-rule-allowlist \
  textlint-filter-rule-comments \
  textlint-filter-rule-node-types \
  textlint-plugin-html \
  textlint-plugin-review \
  textlint-plugin-rst \
  textlint-plugin-satsuki \
  textlint-plugin-latex2e \
  # textlint-plugin-asciidoc-loose \
  textlint-plugin-asciidoctor \
  textlint-plugin-jsx

COPY .textlintrc /
WORKDIR /work

ENTRYPOINT []
