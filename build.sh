#!/usr/bin/env bash
set -e

DEBUG=${DEBUG:-false}
$DEBUG && set -x || set +x

BASE_DIR=${BASE_DIR:-`cd "$(dirname "$0")"; pwd`}

config=config
[ -r $config ] || config=$config.sample
source "$BASE_DIR/$config"

_README() {
  asciidoctor README.adoc
}

_build() {
  asciidoctor $asciidoctor_attrs -D "$html_dir" $doc
  ( cd src/docs/asciidoc; rsync -a images "$BASE_DIR/$html_dir/" )
}

_pdf() {
  asciidoctor-pdf $asciidoctor_attrs -o $pdf_name -D "$pdf_dir" $doc
}

_clean() {
  rm -rf $build_dir
}

_publish() {
  local published_dir=`mktemp -d`
  local remote_repo=`git config --get remote.origin.url`

  if [ ".$remote_repo" = "." ]
  then
    echo 'The remote repository is not configured!'
    return 1
  fi

  mkdir -p "$published_dir"

  cd build/asciidoc/html5
  rsync -am \
    --include='**/' \
    --include='/index.html' \
    --include='/images/**' \
    --exclude='*' \
    . "$published_dir"/
  cd - &> /dev/null

  cd build/asciidoc/pdf
  [ -r $pdf_name ] || cp index.pdf $pdf_name
  cp $pdf_name "$published_dir"/
  cd - &> /dev/null

  tree -a "$published_dir"

  local msg="Published at `date`"
  cd "$published_dir"
  git init
  git add -A
  git commit -m "$msg"
  git push --force $remote_repo master:gh-pages
  cd - &> /dev/null
}

op=${1:-build}
cd "$BASE_DIR"
type _$op &> /dev/null || exit 1
_$op
