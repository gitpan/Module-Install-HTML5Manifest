use strict;
use warnings;
use Test::More;
use Capture::Tiny 'capture';
use File::Spec;
use IO::Uncompress::Gunzip 'gunzip';

my $example = File::Spec->catfile('t', 'Zlib');
chdir $example;

my($stdout, $stderr) = capture {
    system $^X, 'Makefile.PL';
    system 'make', 'html5manifest';
};

ok(-f 'example.manifest.gz');

gunzip('example.manifest.gz' => \my $manifest);

unless ($manifest) {
    require IO::Dir;
    my $dir = IO::Dir->new('.');

    warn "show stdout: \n$stdout\n";
    warn "show stderr: \n$stderr\n";

    warn "show current directory for debug";
    while (defined(my $entry = $dir->read)) {
        warn sprintf "# %s (%d bytes) ", $entry, -s $entry;
    }
}

is($manifest, <<MANIFEST);
CACHE MANIFEST

NETWORK:
/api
/foo/bar.cgi

CACHE:
/site.css
/site.js

# digest: KC22SJMksgNahFOXL97t7w
MANIFEST

capture {
    system 'make', 'distclean';
};

done_testing;
