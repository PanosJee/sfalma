# Sfalma <http://sfalma.com>

Sfalma helps you track errors in your Ruby apps, this gem is a fork of Exceptional.

This Gem/Plugin posts exception data to Sfalma <http://sfalma.com>. Data about the request, session, environment and a backtrace of the exception is sent.

## Rails 2.x Installation

1. Install the Gem
<pre>gem install sfalma</pre>
2. Add config.gem entry to 'config/environment.rb'
<pre>config.gem 'sfalma'
3. Create your account and app at <http://sfalma.com>
4. Configue your API Key
<pre>$ sfalma install <api-key></pre>
using the api-key from the app settings screen within Sfalma
5. Test with <pre>sfalma test</pre>

## Rails 3 Installation

1. Add  gem entry to Gemfile
<pre>config.gem 'sfalma'</pre>
2. Run <pre>bundle install</pre>
3. Create your account and app at <http://sfalma.com>
4. Configure your API Key
<pre>$ sfalma install <api-key></pre>
using the api-key from the app settings screen within Sfalma
5. Test with <pre>sfalma test</pre>


### Sfalma also supports your rack, sinatra and plain ruby apps
For more information check out our docs site <http://www.sfalma.com/docs>

Copyright © 2011 Sfalma.
Copyright © 2008, 2010 Contrast.
