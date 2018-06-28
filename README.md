# GetConf

A simple configuration manager for namespaced modules.

## Installation

The package can be installed
by adding `get_conf` to your list of dependencies in `mix.exs`:

```elixir
{:get_conf, "~> 0.1.0"},
```

## Usage

Define your configuration in your `config/{env}.exs`:

    use Mix.Config

    config :app_name, AppName, key: "value"

And access it in your modules. It will go further up the namespace,
to find a matching key in the configuration of each module.

    GetConf.get_conf(:app_name, AppName, :key)
    # => "value"

    GetConf.get_conf(:app_name, AppName.Module, :key)
    # => "value"

## Macro

You can also use the GetConf module inside your module, to implement `get_conf/1` and `set_conf/2`.

    defmodule TestModule
      use GetConf, otp_app: :app_name
    end

    "bar" = TestModule.get_conf(:foo)

## Documentation

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can be found at [https://hexdocs.pm/get_conf](https://hexdocs.pm/get_conf).
