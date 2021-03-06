FROM python:alpine as py
FROM node:alpine
LABEL maintainer="ebal5 on GitHub <eval.scheme@gmail.com>" \
  version=1.5 \
  description="textlint with python and many rules"
COPY --from=py /usr/local/ /usr/local
RUN apk update && apk add --no-cache git
RUN npm install --global \
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
  textlint-plugin-asciidoctor \
  textlint-plugin-jsx
COPY .textlintrc /root
WORKDIR /work
ENTRYPOINT []
