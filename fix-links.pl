#!/usr/bin/env perl
use strict;
use warnings;

my $target = shift @ARGV or die "Usage: $0 <vercel|cloudflare> [files...]\n";

my %domains = (
  vercel     => 'https://holy-bible-matters.vercel.app',
  cloudflare => 'https://holy-bible-matters.pages.dev',
);

my $new = $domains{$target} or die "Unknown target: $target\n";
my $old = quotemeta('https://holy-bible-matters.github.io');

# Включаем in-place редактирование
$^I = '';

while (<>) {
  # 1. Защищаем canonical, og:url, twitter:url
  if (/rel=["']canonical["']/ || /property=["']og:url["']/ || /name=["']twitter:url["']/) {
    print;
    next;
  }

  # 2. Защищаем специальные ссылки вида <a ...>https://holy-bible-matters.github.io/</a>
  if (m|>https://holy-bible-matters\.github\.io/?</a>|) {
    print;
    next;
  }

  # 3. Меняем домен во всех остальных местах
  s/$old/$new/g;

  print;
}