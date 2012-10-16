A tool for side-by-side double blinded user testing of search engine
result preferences. Using the [bento_search](http://github.com/jrochkind/bento_search)
library.

If you wanted to use this yourself, I suggest simply forking the project on
github. At a minimum you'll want to customize search engine setup configuration
in ./config/initializers/bento_search.rb, you may want to customize more. 

Run `bundle update` to get latest dependencies after checkout, as you'll have the
in Gemfile.lock from the repo. Or just `bundle update bento_search` to make sure
you're using the latest bento_search from git. 

An overview of results are available in a running app at `/results`. There is
no built in auth protection for results page; suggest protecting it at the apache
level (possibly making it non-viewable until your study is complete). 
