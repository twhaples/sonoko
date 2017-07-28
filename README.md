# Sonoko

Runs all the tests related to your diff.


![amusing image](http://i.imgur.com/MR3hYYK.jpg)

## Architecture

Sonoko needs to understand your tests first, so it runs the test suite
with a trace function installed to generate a method-to-test
mapping. Then when you modify your code, it notes the affected method,
and invokes the appropriate examples.

You should probably analyze the database nightly (or thereabouts) and
put a copy where your computer can access it in the morning.

(You definitely should not check it into version control.)

## Usage

The `sonoko-trace` executable assumes it is installed in `bin/` in the
root of the project that needs to be traced. Add `sonoko` to your
Gemfile and run

``` shellsession
bundle binstub sonoko
bin/sonoko analyze spec/ # or equivalent rspec arugments
```

This creates a SQLite3 database `tests.db` in your project root.

`bin/sonoko dump` will dump the contents of this database, because you
like debugging I guess?

A future command will take method names and invoke those examples with rspec.

----

![amusing .gif](https://media.giphy.com/media/3ohryhYAObzCVnZQAg/giphy.gif)
