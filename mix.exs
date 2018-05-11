defmodule TesseractTrees.MixProject do
  use Mix.Project

  def project do
    [
      app: :tesseract_trees,
      version: "0.1.1",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
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
      {:tesseract_geometry, "~> 0.1.1"},
      {:tesseract_ext, "~> 0.1.0"},
    ]
  end

  defp description() do
    "Tempo-spatial indexing structures implemented in Elixir."
  end

  defp package() do
    [
      name: "tesseract_trees",
      maintainers: ["Urban Soban"],
      licenses: ["MIT"],
      links: %{
        "github" => "https://github.com/tesseract-libs/tesseract-trees",
        "tesseract.games" => "http://tesseract.games"
      },
      organisation: "tesseract",
      files: ["lib", "test", "config", "mix.exs", "README*", "LICENSE*"]
    ]
  end
end
