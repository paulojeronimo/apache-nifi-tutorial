#!/usr/bin/env bash

BASE_DIR=${BASE_DIR:-`cd "$(dirname "$0")"; pwd`}
cd "$BASE_DIR"

build_dir=build
build_docs_dir=$build_dir/asciidoc
html_dir=$build_docs_dir/html5
pdf_dir=$build_docs_dir/pdf
pdf_name=apache-nifi-tutorial.pdf

doc=src/docs/asciidoc/index.adoc
attrs="-a projectdir=$BASE_DIR"

_build() {
  asciidoctor $attrs -D "$html_dir" $doc
  ( cd src/docs/asciidoc; rsync -a images "$BASE_DIR/$html_dir/" )
}

_pdf() {
  asciidoctor-pdf $attrs -o $pdf_name -D "$pdf_dir" $doc
}

_clean() {
  rm -rf $build_dir
}

op=${1:-build}
type _$op &> /dev/null && _$op || true
