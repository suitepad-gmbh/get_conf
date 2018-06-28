defmodule GetConf do
  @moduledoc """
  A simple configuration manager for namespaced modules.

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
  """

  defmacro __using__(opts) do
    otp_app = Keyword.fetch!(opts, :otp_app)

    quote do
      def get_conf(key) do
        GetConf.get_conf(unquote(otp_app), __MODULE__, key)
      end

      def set_conf(key, value) do
        GetConf.set_conf(unquote(otp_app), __MODULE__, key, value)
      end
    end
  end

  def get_conf(_otp_app, :"Elixir", _key), do: nil

  @doc """
  Get a value out of a configured keyword list from the given application/module.

  * `otp_app`: The name of the otp application
  * `module`: The module
  * `key`: The key from the Keyword list ot fetch

  Returns `nil` or the value from the configuration.

  ## Examples

      iex> Application.put_env(:get_conf, TestModule, [foo: "bar"])
      iex> GetConf.get_conf(:get_conf, TestModule, :foo)
      "bar"
  """
  def get_conf(otp_app, module, key) when is_atom(otp_app) do
    with list when is_list(list) <- Application.get_env(otp_app, module, []),
         {:ok, value} <- Keyword.fetch(list, key) do
      value
    else
      _ ->
        parent =
          Module.split(module)
          |> Enum.slice(0..-2)
          |> Module.concat()

        get_conf(otp_app, parent, key)
    end
  end

  @doc """
  Set a value on the keyword list of the given application/module.

  * `otp_app`: The name of the otp application
  * `module`: The module
  * `key`: The key from the Keyword list ot fetch
  * `value`: The value to set

  Raises a `RuntimeError` if the configuration is not a keyword list.

  ## Examples

      iex> GetConf.set_conf(:get_conf, TestModule, :foo, "value")
      iex> Application.get_env(:get_conf, TestModule)
      [foo: "value"]
  """
  def set_conf(otp_app, module, key, value) when is_atom(otp_app) do
    case Application.get_env(otp_app, module) do
      current_configuration when is_list(current_configuration) ->
        new_configuration = Keyword.put(current_configuration, key, value)
        Application.put_env(otp_app, module, new_configuration)

      value ->
        raise "Cannot set conf on non-list: #{otp_app}, #{module}, #{inspect(value)}"
    end
  end
end
