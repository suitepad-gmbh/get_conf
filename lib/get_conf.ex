defmodule GetConf do
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
