package Lazy;

use v5.32;
use utf8;
use strict;
use warnings;

use Exporter 'import';

our @EXPORT = qw/lazy/;

sub lazy(&) {
    return Lazy->new($_[0]);
}

use overload
    '""' => sub {
        my $s = shift->{sub}->();
        return "$s";
    },
    "0+" => sub { int(shift->{sub}->()) },
    "+" => sub {
        my ($self, $other, $reverse) = @_;
        return $reverse ?
            lazy { int($other) + int($self) }:
            lazy { int($self) + int($other) };
    },
    "-" => sub {
        my ($self, $other, $reverse) = @_;
        return $reverse ?
            lazy { int($other) - int($self) }:
            lazy { int($self) - int($other) };
    };

sub new {
    my ($class, $sub) = @_;
    return bless { sub => $sub }, $class;
}

sub set {
    my ($self, $v) = @_;
    $self->{sub} = sub { $v };
}

1;
