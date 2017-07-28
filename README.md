# Sonoko

Runs all the tests related to your diff.


![Let's Enjoy Kagawa Life!](http://i.imgur.com/MR3hYYK.jpg)

## Architecture

Sonoko needs to understand your tests first, so it runs the test suite
with a trace function installed to generate a method-to-test
mapping. Then when you modify your code, it notes the affected method,
and invokes the appropriate examples.

You should probably analyze the database nightly (or thereabouts) and
put a copy where your computer can access it in the morning.

(You definitely should not check it into version control.)

## Setup

Add `sonoko` to your Gemfile or gemspec. Optionally, invoke:

``` shellsession
bundle binstub sonoko

```

This will set up `bin/sonoko` for your project.
(You can commit this binstub or ignore it, at your discretion.)

## Analysis
```  shellsession
sonoko reset
sonoko analyze
```

`analyze` creates a database (by default, `tests.db` in your project
root) if it does not exist, runs specs (defaulting to `spec/`) and
populates it. If you have multiple testrunner invocations in your
project, you can make multiple calls to `analyze` and they will
add records incrementally.

`reset` erases any existing database.

## Use

`bin/sonoko relevant` will read a list of method names on `STDIN` and
output relevant spec locations.

A future command will determine relevant method names by
 - looking at the git repository before and after
 - parsing the AST
 - looking for changes in the AST
 - walking down the diff to find methods removed by the change
 - walking back up the AST to find affected methods around this change

A future command will take method names and invoke the relevant
examples with rspec. It will also run any *modified* tests.

## Performance

Let's try this just on one spec:

```
inubozaki-fuu:payments-service$ time bin/rspec 'spec/models/registration_spec.rb'

real	1m6.085s
user	0m54.725s
sys     0m5.719s
```


```
inubozaki-fuu:payments-service$ time bin/sonoko analyze --vebose 'spec/models/registration_spec.rb'

real	8m16.908s
user	6m50.064s
sys     0m41.314s
```

It takes about 6 times longer; you're probably going to want to run
that overnight. You can run this on CircleCI and get parallelism; run
it in verbose mode (to reassure Circle) and possibly bump up the idle
timeout.

```
test:
  override:
    - bin/sonoko analyze --verbose:
        parallel: true
        files:
          - spec/**/*_spec.rb
general:
  artifacts:
    - tests.db
```
Merging databases will be required.

## Amusement
![amusing .gif](https://media.giphy.com/media/3ohryhYAObzCVnZQAg/giphy.gif)
