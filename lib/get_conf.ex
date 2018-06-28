defmodule GetConf do
  defmacro __using__(opts) do
    otp_app = Keyword.fetch!(opts, :otp_app)

    quote do
      def get_conf(key) do
        GetConf.get_conf(unquote(otp_app), __MODULE__, key)
      end
    end
  end

  def get_conf(_otp_app, :"Elixir", _key), do: nil

  def get_conf(otp_app, module, key) do
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
end
