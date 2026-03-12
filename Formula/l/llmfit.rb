class Llmfit < Formula
  desc "Find what models run on your hardware"
  homepage "https://github.com/AlexsJones/llmfit"
  url "https://github.com/AlexsJones/llmfit/archive/refs/tags/v0.6.7.tar.gz"
  sha256 "e0e477690b9286e0cb82c72dc9289984b6dfd0cb4f8e2894c93c7a050a28bc76"
  license "MIT"
  head "https://github.com/AlexsJones/llmfit.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "d25c424bd10780f68d858a0b208442d5363b88e878c97cc6981b670124fcd751"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "8d2be8eade344a7de40876aa9ae572a477cea68304ee0c43d05c6b014704e20a"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "78b3135223c2cac0cdf3355340674a1a1f5b3af23d55281b6bc80fae0a21a549"
    sha256 cellar: :any_skip_relocation, sonoma:        "a2419209f222adf975ff0546f7fe412b8d9fb88e088887837aa7ab72b30399b9"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "358dff1e5e919b21ec069b322a5011d3cc0c9797520153708df5a834bd709606"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "33a0179ddec61fd7c43bf374021243c7e219679dea8a7f0d47a5169fb505d45a"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args(path: "llmfit-tui")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/llmfit --version")
    assert_match "Multiple models found", shell_output("#{bin}/llmfit info llama")
  end
end
