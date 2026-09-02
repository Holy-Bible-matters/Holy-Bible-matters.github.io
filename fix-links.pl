#!/usr/bin/env perl
use strict;
use warnings;
use File::Find;

my $target = shift @ARGV or die "Usage: $0 <vercel|cloudflare>\n";

my %domains = (
  vercel     => 'https://holy-bible-matters.vercel.app',
  cloudflare => 'https://holy-bible-matters.pages.dev',
);

my $new = $domains{$target} or die "Unknown target\n";
my $old = 'https://holy-bible-matters.github.io';

find(sub {
  return unless -f && /\.html$/;

  open my $in, '<', $_ or return;
  local $/;
  my $content = <$in>;
  close $in;

  my $original = $content;

  # 1. Защита canonical, og:url, twitter:url
  my @protected;
  $content =~ s{(<(?:link|meta)[^>]*(?:rel=["']canonical["']|property=["']og:url["']|name=["']twitter:url["'])[^>]*>)}{
    push @protected, $1;
    "___PROTECTED_" . $#protected . "___"
  }ge;

  # 2. Защита специальных ссылок
  $content =~ s{(<a[^>]*href=["']\Q$old\E/?["'][^>]*>https://holy-bible-matters\.github\.io/?</a>)}{
    push @protected, $1;
    "___PROTECTED_" . $#protected . "___"
  }ge;

  # 3. Замена домена
  $content =~ s/\Q$old\E/$new/g;

  # 4. Возврат защищённых частей
  $content =~ s/___PROTECTED_(\d+)___/$protected[$1]/g;

  if ($content ne $original) {
    open my $out, '>', $_ or warn "Cannot write $File::Find::name\n";
    print $out $content;
    close $out;
  }
}, '.');