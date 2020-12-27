# OCaml bindings to [`signal-cli`](https://github.com/AsamK/signal-cli) DBus API

This OCaml library provides bindings to the DBus API provided by
[`signal-cli`](https://github.com/AsamK/signal-cli), a command-line front-end
for the [_Signal_ messaging platform](https://signal.org/en/).  It can be used
to accomplish various tasks such as:

- Building a custom _Signal_ chat client (or, say, integrating it into your
  favorite text editor, i.e. _Emacs_).

- Building a _Signal_ chat-bot.  You can use the `signal.api` library to setup
  a simple chat-bot with just a few lines of code, or use the
  [Elm](https://guide.elm-lang.org/architecture/)-like `signal.bot` framework
  to build a more sophisticated, stateful chat-bot.  See the
  [examples](#examples) for a primer on how to do so.

### The `signal.api` library

### The `signal.bot` framework

## Setup and usage

## Examples

### A basic _stateless_ chat bot

### A basic _stateful_ chat bot
