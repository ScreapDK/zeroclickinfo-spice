package DDG::Spice::Quixey;

use DDG::Spice;
use JSON;
use String::Trim;
use List::Uniq ':all';

# Variable Definitions
my %custom_ids = (2005 => 75675980, 2004 => 78989893);

my %platform_ids = (
	"android" => 2005,
	"droid" => 2005,
	"google play store" => 2005,
	"google play" => 2005,
	"windows phone 8" => 8556073,
	"windows phone" => 8556073,
	"windows mobile" => 8556073,
	"playbook" => 2008,
	"blackberry" => 2008,
	"apple app store" => 2004,
	"apple app" => 2004,
	"ios" => 2004,
	"ipod touch" => 2004,
	"ipod" => 2004,
	"iphone" => 2004,
	"ipad" => 2015,
);

my @triggers = keys %platform_ids;
my @extraTriggers = qw(quixey app apps);
push(@triggers, @extraTriggers);

triggers any => @triggers;

spice from => '([^/]+)/([^/]+)/?([^/]+)?/?([^/]+)?';

spice to => 'https://api.quixey.com/1.0/search?partner_id=2073823582&partner_secret={{ENV{DDG_SPICE_QUIXEY_APIKEY}}}&q=$1&platform_ids=$2&max_cents=$3&custom_id=$4&limit=50&skip=0&format=json&callback={{callback}}';

spice proxy_ssl_session_reuse => "off";

handle query_parts => sub {
	
	my $full_query = join(" ", @_);
	my $restriction;
	my $max_price = 999999;

	$max_price = 0 if ($full_query =~ s/\bfree\b//ig);
	
	my @matches = grep { $full_query =~ /\b$_\b/ig } sort { length($a) <=> length($b) } keys %platform_ids;
	if (length scalar @matches){
		my @sorted_matches = sort { length($b) <=> length($a) } @matches;
		foreach my $match (@sorted_matches){
			$full_query =~ s/\b$match\b//ig;
			$restriction = $platform_ids{ $match };
		}
	}

	$full_query =~ s/\b$_\b//ig foreach (@extraTriggers);
	$full_query =~ s/\s+/ /ig;
	$full_query = trim $full_query;
	return unless (length $full_query);

	if (defined $restriction) {
		my @platforms = ();
		$platforms[0] = $restriction;
		my $platforms_encoded = encode_json \@platforms;
		if ($restriction == 2005 or $restriction == 2004) {
			return $full_query, $platforms_encoded, $max_price, $custom_ids{ $restriction };
		} else {
			return $full_query, $platforms_encoded, $max_price, "2414062669";
		}
	} else {
		my @full_platforms = uniq (values %platform_ids);
		my @platforms = ();
		foreach my $element(@full_platforms) {
			if (defined $element and $element ne 0) {
				push @platforms, int($element);
			}
		}
		my $platforms_encoded = encode_json \@platforms;
		return $full_query, $platforms_encoded, $max_price, "2414062669";
	}
	return;
};

1;
