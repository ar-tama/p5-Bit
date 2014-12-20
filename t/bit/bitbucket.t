use strict;
use warnings;
use Test::More;
use Bit::CLI;
use Test::Mock::Guard qw(mock_guard);

my $g = mock_guard(
    Bit => {
        _call => sub {
            my ($self, $command) = @_;
            if ($command eq 'git remote -v') {
                return (
                    'origin	git@bitbucket.org:ar_tama/Bit.git (fetch)',
                    'origin	git@bitbucket.org:ar_tama/Bit.git (push)'
                );
            }
            else {
                return `$command`;
            }
        }
    }
);
my $bit = Bit->new;


subtest 'open' => sub {
    my $result;
    my $guard = mock_guard(
        Bit => {
            _call => sub { shift; $result = shift }
        }
    );
    $bit->open;
    is $result, 'open https://bitbucket.org/ar_tama/Bit';
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
        is $result, "open 'https://bitbucket.org/ar_tama/Bit/pull-request/new'";
    };

    subtest 'with base branch' => sub {
        my $current = `git symbolic-ref --short HEAD`;
        chomp $current;
        $bit->pr({base => 'development'});
        is $result, "open 'https://bitbucket.org/ar_tama/Bit/pull-request/new'"; # ignored
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
        is $result, "open 'https://bitbucket.org/ar_tama/Bit/compare/master..$current'";
        $bit->compare({head => 'current'});
        is $result, "open 'https://bitbucket.org/ar_tama/Bit/compare/master..$current'";
    };

    subtest 'with head, base branch' => sub {
        my $current = `git symbolic-ref --short HEAD`;
        chomp $current;
        $bit->compare({head => 'development', base => 'master'});
        is $result, "open 'https://bitbucket.org/ar_tama/Bit/compare/master..development'";
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
        is $result, "open 'https://bitbucket.org/ar_tama/Bit/pull-requests'";
    };

    subtest 'with num' => sub {
        $bit->pulls({id => 12});
        is $result, "open 'https://bitbucket.org/ar_tama/Bit/pull-request/12'";
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
        is $result, "open 'https://bitbucket.org/ar_tama/Bit/issues'";
    };

    subtest 'with num' => sub {
        $bit->issues({id => 12});
        is $result, "open 'https://bitbucket.org/ar_tama/Bit/issue/12'";
    };
};

done_testing;
