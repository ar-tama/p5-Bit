package Bit::CLI;

use strict;
use warnings;
use Bit;
use Getopt::Compact::WithCmd;

sub run {
    my ($class, %args) = @_;
    my $go = Getopt::Compact::WithCmd->new(
        command_struct => {
            open => {
                desc => 'Show your repo.',
            },
            pr => {
                options => [
                    [ [qw/b base/], 'base branch(default:master)', '=s' ],
                    [ [qw/s silent/], 'Just dump PR url.' ],
                ],
                desc => 'Create PR, see "bit help pr".',
                other_usage => 'bit pr -b [base branch(default:master)]',
            },
            compare => {
                options => [
                    [ [qw/b base/], 'base branch(default:master)', '=s' ],
                    [ [qw/h head/], 'head branch(default:current branch)', '=s' ],
                ],
                desc => 'Compare branches, see "bit help compare".',
                other_usage => 'bit compare -h [head branch(default:current)] -b [base branch(default:master)]',
            },
            pulls => {
                options => [
                    [ [qw/i id/], 'pulls id', '=i' ],
                ],
                desc => 'Show PR or PRs, see "bit help pulls".',
                other_usage => 'bit pulls -i [pulls id]',
            },
            issues => {
                options => [
                    [ [qw/i id/], 'issues id', '=i' ],
                ],
                desc => 'Show issues, see "bit help issues".',
                other_usage => 'bit issues -i [issue id]',
            },
        },
    );
    my $opts = $go->opts;
    my $cmd  = $go->command || $go->show_usage;

    my $bit = Bit->new(%args);
    if (my $code = $bit->can($cmd)) {
        $code->($bit, $opts);
    }
    else {
        $go->show_usage;
    }
}

1;
