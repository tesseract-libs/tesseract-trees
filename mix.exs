defmodule TesseractTrees.MixProject do
  use Mix.Project

  def project do
    [
      app: :tesseract_trees,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      source_url: "https://github.com/tesseract-libs/tesseract-trees",
      homepage_url: "http://tesseract.games"
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
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end

  defp description() do
    "Tempo-spatial indexing structures implemented in Elixir."
  end

  defp package() do
    [
      name: "tesseract_trees",
      maintainers: ["Urban Soban"],
      licences: ["MIT"],
      links: %{
        "tesseract.games" => "http://tesseract.games"
      },
      organisation: "tesseract",
    ]
  end
end
