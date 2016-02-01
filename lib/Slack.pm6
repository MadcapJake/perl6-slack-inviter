unit class Slack;

has $.token;
has $.url;

method slack-request($http-meth, *%data) {
  my $queries = %data.map({$_.kv.join('=')}).join('&');
  given $http-meth {
    when 'GET' {
      return Proc::Async.new('curl',
        "https://$!url/api/users.admin.invite", '--data',
        'token=' ~ $!token ~ "\&$queries", '--compressed');
    }
    when 'POST' {
      return Proc::Async.new('curl', '-X', $http-meth,
        "https://$!url/api/users.admin.invite", '--data',
        'token=' ~ $!token ~ "\&$queries", '--compressed');
    }
  }
}

method invite-request($email) {
  self.slack-request('POST', :$email, :set-active)
}

method usrdat-request() {
  self.slack-request('GET', :presence)
}
