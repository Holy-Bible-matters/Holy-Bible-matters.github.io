#!/usr/bin/env perl
use strict;
use warnings;
use File::Find;
use File::Slurp qw(read_file write_file); # если нет - используем ниже вариант без него

my $target = shift @ARGV or die "Usage: $0 <vercel|cloudflare>\n";

my %domains = (
  vercel     => 'https://holy-bible-matters.vercel.app',
  cloudflare => 'https://holy-bible-matters.pages.dev',
);

my $new = $domains{$target} or die "Unknown target\n";
my $old = 'https://holy-bible-matters.github.io';

find(sub {
  return unless -f && /\.html$/;

  open my $fh, '<', $_ or return;
  local $/;
  my $content = <$fh>;
  close $fh;

  my $original = $content;

  # Защищаем canonical / og:url / twitter:url (временно заменяем на плейсхолдеры)
  my @protected;
  $content =~ s{(<(?:link|meta)[^>]*(?:rel=["']canonical["']|property=["']og:url["']|name=["']twitter:url["'])[^>]*>)}{
    push @protected, $1;
    "___PROTECTED_" . $#protected . "___"
  }ge;

  # Защищаем специальные ссылки "текст = адрес GitHub"
  $content =~ s{(<a[^>]*href=["']$old/?["'][^>]*>https://holy-bible-matters\.github\.io/?</a>)}{
    push @protected, $1;
    "___PROTECTED_" . $#protected . "___"
  }ge;

  # Меняем домен везде
  $content =~ s/\Q$old\E/$new/g;

  # Возвращаем защищённые куски
  $content =~ s/___PROTECTED_(\d+)___/$protected[$1]/g;

  if ($content ne $original) {
    open my $out, '>', $_ or warn "Cannot write $_\n";
    print $out $content;
    close $out;
  }
}, '.');