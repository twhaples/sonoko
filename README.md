# Sonoko

Runs all the tests related to your diff.

![amusing .gif](https://media.giphy.com/media/3ohryhYAObzCVnZQAg/giphy.gif)

## Architecture

Sonoko needs to understand your tests first, so it runs the test suite
with a trace function installed to generate a method-to-test
mapping. Then when you modify your code, it notes the affected method,
and invokes the appropriate examples.

## Usage

The `sonoko-trace` executable assumes it is installed in `bin/` in the
root of the project that needs to be traced. Add `sonoko` to your
Gemfile and run

``` shellsession
bundle binstub sonoko
bin/sonoko-trace spec/ # or equivalent rspec arugments
```


This will output a JSON mapping: class and method name to

At some point it will output SQLite instead. Or maybe a real database.
It'll be fun!
