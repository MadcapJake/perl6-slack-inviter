use Bailador;
use Bailador::Template::Mustache;
use JSON::Fast;

Bailador::import();

my $community = 'Perl 6';
my $slack-url = 'perl6.slack.com';
my $token     = %*ENV<SLACK_TOKEN>;

my %templates =
  from => './views',
  extension => '.hbs';

get '/' => sub {
  Template::Mustache.render(slurp('./views/index.hbs'),
    { community => "Perl 6" }, |%templates);
}

post '/invite' => sub {
  my $curl = Proc::Async.new('curl', '-X', 'POST',
    "https://$slack-url/api/users.admin.invite",
    '--data',
      'email=' ~ request.params<email> ~
      '&token=' ~ $token ~
      '&set_active=true',
    '--compressed');
  my %res;
  $curl.stdout.tap(-> $json { %res = from-json($json) });
  await $curl.start;
  say %res;
  if %res<ok>.so {
    return Template::Mustache.render(slurp('./views/result.hbs'), {
      :$community, message => 'Success! Check ' ~ request.params<email>
        ~ ' for an invite from Slack.'}, |%templates);
  } else {
    my $error = %res<error>;
    my $message;
    if ($error ~~ 'already_invited' or $error ~~ 'already_in_team') {
      return Template::Mustache.render(slurp('./views/result.hbs'), {
        :$community,
        :message('Success! You were already invited.<br>' ~
          "Visit the <a href=\"https://$slack-url\">{$community}</a> Slack.")
      }, |%templates);
    } elsif $error ~~ 'invalid_email' {
      $message = 'The email you entered is an invalid email.';
    } elsif $error ~~ 'invalid_auth' {
      $message = 'Something has gone wrong.  Please contact system administrator';
    }
    return Template::Mustache.render(slurp('./views/result.hbs'),
      {:$community, :$message, :failed('error')}, |%templates);
  }
}

get '/css/style.css' => sub {
  content_type('text/css');
  slurp './css/style.css'
}

baile(%*ENV<PORT>);
say 'Running bailador app on port:' ~ $*ENV<PORT>;
