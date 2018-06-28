defmodule GetConf.MixProject do
  use Mix.Project

  def project do
    [
      app: :get_conf,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      description: "A simple configuration manager for namespaced modules.",
      deps: deps(),
      package: package(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp package do
    [
      name: "get_conf",
      links: %{},
      licenses: ["MIT"],
      maintainers: ["Suitepad Developers <engineering@suitepad.de>", "Lukas Rieder <l.rieder@gmail.com>"],
      source_url: "https://github.com/suitepad-gmbh/get_conf"
    ]
  end

  defp docs do
    [
      main: "GetConf"
    ]
  end
end
