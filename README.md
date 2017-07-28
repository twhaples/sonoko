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

The `sonoko-trace` executable assumes it is installed in `bin/` in the
root of the project that needs to be traced. Add `sonoko` to your
Gemfile and run

Optionally, invoke:

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

A future command will determine relevant method names.

A future command will take method names and invoke the relevant
examples with rspec.

----

![amusing .gif](https://media.giphy.com/media/3ohryhYAObzCVnZQAg/giphy.gif)
