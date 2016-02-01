unit class Slack;

has $.token;
has $.url;

method slack-request($http-meth, $api-url, *%data) {
  my $queries = %data.map({$_.kv.join('=')}).join('&');
  given $http-meth {
    when 'GET' {
      return Proc::Async.new('curl',
        "https://$!url/api/$api-url", '--data',
        'token=' ~ $!token ~ "\&$queries", '--compressed');
    }
    when 'POST' {
      return Proc::Async.new('curl', '-X', $http-meth,
        "https://$!url/api/$api-url", '--data',
        'token=' ~ $!token ~ "\&$queries", '--compressed');
    }
  }
}

method invite-request($email) {
  self.slack-request('POST', 'users.admin.invite', :$email, :set-active)
}

method usrdat-request() {
  self.slack-request('GET', 'users.list', :presence)
}
