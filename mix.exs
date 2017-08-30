defmodule Extra.Mixfile do
  use Mix.Project

  def project do
    [app: :extra,
     version: "0.1.0",
     build_path: "_build",
     config_path: "config/config.exs",
     deps_path: "deps",
     lockfile: "mix.lock",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     dialyzer: [
       plt_add_deps: :transitive,
       ignore_warnings: "./.dialyzer-ignore-warnings.txt"
     ],
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:cortex, "~> 0.2.1", only: [:test, :dev], runtime: !ci_build?()},
      {:shorter_maps, "~> 2.1"},
      {:flow, "~> 0.12", optional: true},
      {:propcheck, "~> 0.0", only: [:test]},
      {:credo, "~> 0.8", only: [:dev, :test]},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
    ]
  end

  defp ci_build?, do: System.get_env("DRONE_COMMIT") != nil || System.get_env("CI") != nil
end
