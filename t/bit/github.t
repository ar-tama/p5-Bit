use strict;
use warnings;
use Test::More;
use Bit::CLI;
use Test::Mock::Guard qw(mock_guard);

my $bit = Bit->new;

subtest 'open' => sub {
    my $result;
    my $guard = mock_guard(
        Bit => {
            _call => sub { shift; $result = shift }
        }
    );
    $bit->open;
    is $result, 'open https://github.com/ar-tama/p5-Bit';
};

subtest 'pr' => sub {
    my $result;
    my $guard = mock_guard(
        Bit => {
            _call => sub { shift; $result = shift }
        }
    );

    subtest 'default' => sub {
        my $current = `git symbolic-ref --short HEAD`;
        chomp $current;
        $bit->pr;
        is $result, "open 'https://github.com/ar-tama/p5-Bit/compare/master...$current?expand=1'";
    };

    subtest 'with base branch' => sub {
        my $current = `git symbolic-ref --short HEAD`;
        chomp $current;
        $bit->pr({base => 'development'});
        is $result, "open 'https://github.com/ar-tama/p5-Bit/compare/development...$current?expand=1'";
    };
};

subtest 'compare' => sub {
    my $result;
    my $guard = mock_guard(
        Bit => {
            _call => sub { shift; $result = shift }
        }
    );

    subtest 'default' => sub {
        my $current = `git symbolic-ref --short HEAD`;
        chomp $current;
        $bit->compare;
        is $result, "open 'https://github.com/ar-tama/p5-Bit/compare/master...$current'";
        $bit->compare({head => 'current'});
        is $result, "open 'https://github.com/ar-tama/p5-Bit/compare/master...$current'";
    };

    subtest 'with head, base branch' => sub {
        my $current = `git symbolic-ref --short HEAD`;
        chomp $current;
        $bit->compare({base => 'master', head => 'development'});
        is $result, "open 'https://github.com/ar-tama/p5-Bit/compare/master...development'";
    };
};

subtest 'pulls' => sub {
    my $result;
    my $guard = mock_guard(
        Bit => {
            _call => sub { shift; $result = shift }
        }
    );

    subtest 'pulls' => sub {
        $bit->pulls;
        is $result, "open 'https://github.com/ar-tama/p5-Bit/pulls'";
    };

    subtest 'with num' => sub {
        $bit->pulls({id => 12});
        is $result, "open 'https://github.com/ar-tama/p5-Bit/pull/12'";
    };
};

subtest 'issues' => sub {
    my $result;
    my $guard = mock_guard(
        Bit => {
            _call => sub { shift; $result = shift }
        }
    );

    subtest 'issues' => sub {
        $bit->issues;
        is $result, "open 'https://github.com/ar-tama/p5-Bit/issues'";
    };

    subtest 'with num' => sub {
        $bit->issues({id => 12});
        is $result, "open 'https://github.com/ar-tama/p5-Bit/issues/12'";
    };
};

done_testing;
