defmodule Extra.Mixfile do
  use Mix.Project

  def project do
    [app: :extra,
     version: "0.1.1",
     elixir: "~> 1.5",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     dialyzer: [
       plt_add_deps: :transitive,
       ignore_warnings: "./.dialyzer-ignore-warnings.txt"
     ],
     name: "Extra",
     deps: deps(),
     package: package(),
     description: description()
    ]
  end

  defp deps do
    [
      {:cortex, "~> 0.2.1", only: [:test, :dev], runtime: !ci_build?()},
      {:shorter_maps, "~> 2.1"},
      {:flow, "~> 0.12", optional: true},
      {:propcheck, "~> 0.0", only: [:test]},
      {:credo, "~> 0.8", only: [:dev, :test]},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev},
    ]
  end

  defp ci_build?, do: System.get_env("DRONE_COMMIT") != nil || System.get_env("CI") != nil

  defp description do
    """
    A collection of extra utilities and extensions to the Elixir standard library
    """
  end

  defp package do
    [
      name: :extra,
      files: [
        "lib",
        "mix.exs",
        "README.md",
        "History.md",
        "LICENSE"
      ],
      maintainers: [
        "Griffin Smith",
        "Ryan Schmukler",
        "Russ Matney",
        "William Carroll",
        "Justin DeMaris"
      ],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/urbint/extra"}
    ]
  end
end
