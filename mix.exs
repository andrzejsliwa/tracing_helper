defmodule TracingHelper.Mixfile do
  use Mix.Project

  def project do
    [app: :tracing_helper,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:mix_test_watch, "~> 0.2", only: :dev},
     {:credo, "~> 0.3", only: [:dev, :test]},
     {:dialyxir, "~> 0.3", only: [:dev]}]
  end

  defp package do
    [
      description: "simple tracing helper",
      files: ["lib", "mix.exs", "README.md"],
      maintainers: ["Andrzej Śliwa"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/andrzejsliwa/tracing_helper",
        "Docs" => "http://hexdocs.pm/tracing_helper/"
      }
    ]
  end

  defp package do
    [
     name: :tracing_helper,
     description: "simple tracing helper",
     files: ["lib","mix.exs", "README.md"],
     maintainers: ["Andrzej Śliwa"],
     licenses: ["MIT"],
     links: %{
        "GitHub" => "https://github.com/andrzejsliwa/tracing_helper",
        "Docs" => "http://hexdocs.pm/tracing_helper/"
      }
    ]
  end
end
