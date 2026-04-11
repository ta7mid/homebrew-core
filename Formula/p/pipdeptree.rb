class Pipdeptree < Formula
  include Language::Python::Virtualenv

  desc "CLI to display dependency tree of the installed Python packages"
  homepage "https://github.com/tox-dev/pipdeptree"
  url "https://files.pythonhosted.org/packages/fc/18/95aa034bf0ce37197f39b79c2b89cb1516bca99d5d1c905d1415716ac5e2/pipdeptree-2.35.0.tar.gz"
  sha256 "e6cb5213d5b4d2c50258ba86f4ae06ced653111c664fe088c379f3c9a4d41562"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, all: "04bb0a01549935b4bb97c38c60efffe05d908af5c6ecc3f70461c47c580d6013"
  end

  depends_on "python@3.14"

  resource "packaging" do
    url "https://files.pythonhosted.org/packages/65/ee/299d360cdc32edc7d2cf530f3accf79c4fca01e96ffc950d8a52213bd8e4/packaging-26.0.tar.gz"
    sha256 "00243ae351a257117b6a241061796684b084ed1c516a08c48a3f7e147a9d80b4"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match "pipdeptree==#{version}", shell_output("#{bin}/pipdeptree --all")

    assert_empty shell_output("#{bin}/pipdeptree --user-only").strip

    assert_equal version.to_s, shell_output("#{bin}/pipdeptree --version").strip
  end
end
