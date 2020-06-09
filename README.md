# Ramverk

Ramverk is a web application framework written in Ruby.

The goal of Ramverk is to keep the core framework as neat as possible and only include basic
functionality like logging, constant autoloading. We rather add, than remove, functionality.

While Ramverk comes with an application generator, the directory structure is not set in stone and
can be adjusted to fit your needs. Start small with only one file and grow into a modular MVC structure.
Or start big directly, your choice.

## Inspirations

- Ruby on Rails
- Phoenix Framework
- Hanami
- Sinatra

## Status

Under development, not ready for prime-time just yet.

[![Build Status](https://travis-ci.org/sandelius/ramverk.svg?branch=master)](https://travis-ci.org/sandelius/ramverk)
[![codecov](https://codecov.io/gh/sandelius/ramverk/branch/master/graph/badge.svg)](https://codecov.io/gh/sandelius/ramverk)
[![Inline docs](http://inch-ci.org/github/sandelius/ramverk.svg?branch=master)](http://inch-ci.org/github/sandelius/ramverk)

## Installation

Ramverk supports Ruby (MRI) 2.5+ and JRuby 9.2+

```
$ gem install ramverk
```

## Usage

```bash
ramverk new petstore
```

```bash
cd petstore && bundle && ramverk server
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sandelius/ramverk. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
