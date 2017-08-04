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

Run the tests relevant to `FooBar.method` and `Bar::Foo#method`:
``` shellsession
bin/sonoko relevant FooBar.method "Bar::Foo#method"
```

A future command automatically will determine relevant method names by
 - looking at the git repository before and after
 - parsing the AST
 - looking for changes in the AST
 - walking down the diff to find methods removed by the change
 - walking back up the AST to find affected methods around this change

It will also run modified tests.

## Performance

Let's try this just on one spec:

```
inubozaki-fuu:payments-service$ time bin/rspec 'spec/models/registration_spec.rb'

real	1m6.085s
user	0m54.725s
sys     0m5.719s
```

```
inubozaki-fuu:payments-service$ time bin/sonoko analyze 'spec/models/registration_spec.rb'

real	8m16.908s
user	6m50.064s
sys     0m41.314s
```

It takes about 6-7 times longer, which is pretty typical. For large
projects, this should generally be run overnight while your
integration cluster would otherwise be idle. For very large projects,
this should further be parallelized.

## CircleCI

You can run this on CircleCI and get parallelism; add the method
option `--keepalive=100000` (to reassure Circle that the command is
still running) and review timeouts if necessary. Actually causing this
test run to happen is left as an exercise to the user; a small bot
capable of submitting a new branch every evening may be provided in
the future.

```
test:
  override:
    - bin/sonoko analyze --keepalive=100000:
        parallel: true
        files:
          - spec/**/*_spec.rb
general:
  artifacts:
    - tests.db
```

Running in parallel will mean that merging databases will be required.
A command to fetch a database via HTTP and merge it into the local
database may be implemented in a future release.

## Mascot

Sonoko is noted for her tendency to fall asleep in class, her family's
substantial
[financial resources](https://media.giphy.com/media/3o7bu2AF6XF1S66BpK/giphy.gif),
and her ability to maintain a calm demeanor in the face of apocalyptic
danger as she fights a hopeless rear-guard action to protect an
all-but-defeated remnant of humanity from utter annihilation at the
hands of ruthless, indefatigable monsters.

She has learned to
[enjoy Kagawa Life](https://www.youtube.com/results?search_query=let%27s+enjoy+kagawa+life)
and to treasure her time with her friends, because she knows that all
things must pass. Her spirit animal is the
[chicken. 🐔](https://media.giphy.com/media/qRbvXeEieHiLe/giphy.gif)

![amusing .gif](https://media.giphy.com/media/jyAaxYquCLYe4/giphy.gif)

Sonoko was chosen as mascot for the assonant sound of the name and the
availability of cool shades ~~(and also because
[Homu](https://github.com/homu) was already taken).~~
