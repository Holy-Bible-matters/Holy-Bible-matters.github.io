#!/usr/bin/env perl
use strict;
use warnings;

my $target = $ARGV[0] or die "Usage: $0 <vercel|cloudflare>\n";

my %domains = (
  vercel     => 'https://holy-bible-matters.vercel.app',
  cloudflare => 'https://holy-bible-matters.pages.dev',
);

my $new = $domains{$target} or die "Unknown target\n";
my $old = quotemeta('https://holy-bible-matters.github.io');

while (<>) {
  # 1. Полностью защищаем canonical, og:url и twitter:url
  if (/rel=["']canonical["']/ || /property=["']og:url["']/ || /name=["']twitter:url["']/) {
    print;
    next;
  }

  # 2. Защищаем специальные ссылки вида <a href="...">https://holy-bible-matters.github.io/</a>
  if (m|>https://holy-bible-matters\.github\.io/?</a>|) {
    print;
    next;
  }

  # 3. Меняем домен во всех остальных местах (href, src, action, url(), data-*, JS и т.д.)
  s|$old|$new|g;

  print;
}