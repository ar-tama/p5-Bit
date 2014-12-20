requires 'perl', '5.008001';

requires 'Carp';
requires 'URI::Template';
requires 'Class::Accessor::Lite';
requires 'Getopt::Compact::WithCmd';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Test::Mock::Guard';
};

