package Bit;
use 5.008005;
use strict;
use warnings;
use feature 'say';
use Carp qw(croak);
use URI::Template;
use Class::Accessor::Lite (
    rw => [qw/domain repo_type templates current_branch/],
);

our $VERSION = "0.01";

sub new {
    my ($class, %args) = @_;
    my $self = bless \%args, $class;
    $self->_init;
    return $self;
}

sub _init {
    my $self   = shift;
    my $domain = $self->_get_domain;
    $self->domain($domain);

    my ($repo_type, $templates);
    if ($domain =~ /github/) {
        $repo_type = 'github';
        $templates = {
            pr      => $self->_generate_subpath_template('compare', '{base_branch}...{head_branch}?expand=1'),
            compare => $self->_generate_subpath_template('compare', '{base_branch}...{head_branch}'),
            pull    => $self->_generate_subpath_template('pull', '{num}'),
            pulls   => $self->_generate_subpath_template('pulls'),
            issue   => $self->_generate_subpath_template('issues', '{num}'),
            issues  => $self->_generate_subpath_template('issues'),
        };
    }
    elsif ($domain =~ /bitbucket/) {
        $templates = {
            pr      => $self->_generate_subpath_template('pull-request', 'new'),
            compare => $self->_generate_subpath_template('compare', '{base_branch}..{head_branch}'),
            pull    => $self->_generate_subpath_template('pull-request', '{num}'),
            pulls   => $self->_generate_subpath_template('pull-requests'),
            issue   => $self->_generate_subpath_template('issue', '{num}'),
            issues  => $self->_generate_subpath_template('issues'),
        };
    }
    else {
        croak 'Currently we only support: github, bitbucket'
    }
    $self->repo_type($repo_type);
    $self->templates($templates);
    my $branch = $self->_call('git symbolic-ref --short HEAD', 0, 1);
    chomp $branch;
    $self->current_branch($branch);
}

sub open {
    my $self = shift;
    $self->_call("open " . $self->domain, 1, 1);
}

sub pr {
    my ($self, $opts) = @_;
    my $base_branch ||= $opts->{base} || 'master';
    my $head_branch   = $self->current_branch;

    my $url = $self->templates->{pr}->process(
        base_branch => $base_branch,
        head_branch => $head_branch
    );
    $self->_call("open '$url'", 1, !$opts->{silent});
}

sub compare {
    my ($self, $opts) = @_;
    my $head_branch = $opts->{head};
    if (!$head_branch || $head_branch eq 'current') {
        $head_branch = $self->current_branch;
    }

    my $base_branch = $opts->{base} || 'master';
    my $url = $self->templates->{compare}->process(
        base_branch => $base_branch,
        head_branch => $head_branch
    );
    $self->_call("open '$url'", 1, 1);
}

sub pulls {
    my ($self, $opts) = @_;
    my $url;
    if (my $num = $opts->{id}) {
        $url = $self->templates->{pull}->process(num => $num);
    }
    else {
        $url = $self->templates->{pulls}->process();
    }
    $self->_call("open '$url'", 1, 1);
}

sub issues {
    my ($self, $opts) = @_;
    my $url;
    if (my $num = $opts->{id}) {
        $url = $self->templates->{issue}->process(num => $num);
    }
    else {
        $url = $self->templates->{issues}->process();
    }
    $self->_call("open '$url'", 1, 1);
}

sub _get_domain {
    my $self    = shift;
    my @remotes = $self->_call('git remote -v', 0, 1);
    unless (@remotes) {
        croak "* You must exec it at git controlled directory.";
    }

    my $source = shift @remotes;
    my $url = '';

    if ($source =~ qr/(http.+)\s.+/) {
        $url = $1;
        $url =~ s/\w+\@|\.git$//g;
    }
    elsif ($source =~ qr/(git\@.+)\s.+/) {
        $url = $1;
        $url =~ s|:|/|;
        $url =~ s|git\@|https://|;
        $url =~ s|.git$||;
    }

    return $url;
}

sub _generate_subpath_template {
    my ($self, @pathes) = @_;
    my $path = join '/', $self->domain, @pathes;
    return URI::Template->new($path);
}

sub _call {
    my ($self, $command, $dump, $exec) = @_;
    say $command if $dump;
    return `$command` if $exec;
}


1;
__END__

=encoding utf-8

=head1 NAME

Bit - Tiny github and bitbucket helper

=head1 SYNOPSIS

    bit [subcommand]
    Run "bit -h" for more informations.

=head1 DESCRIPTION

bit is github and bitbucket helper like hub command.

=head1 LICENSE

Copyright (C) ar_tama.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

ar_tama E<lt>arata.makoto at gmail.comE<gt>

=cut

