class Oxlint < Formula
  desc "High-performance linter for JavaScript and TypeScript written in Rust"
  homepage "https://oxc.rs/"
  url "https://github.com/oxc-project/oxc/archive/refs/tags/oxlint_v1.54.0.tar.gz"
  sha256 "883293e6f30e0794a26b485592116a988cc47946602829c1142561cbb02f3277"
  license "MIT"
  head "https://github.com/oxc-project/oxc.git", branch: "main"

  livecheck do
    url :stable
    regex(/^oxlint_v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "33390e8c62100b8152f299129f41c5951e7ed212276a72db7be25bd4ea72e282"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "447697dc8c4ad083c7d0f882c82dace1f40e9bb6486679487b6ace7c50aa7bdc"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "9732f0d87704e654f3f8ee36b21e0f2e8074b5b35980b503c8aa7bba27f2cab5"
    sha256 cellar: :any_skip_relocation, sonoma:        "d0f8f93b744782746789be3a24d06fb991d33c9aae5d17199d602b738216e6d5"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "4d6342395be8f22fc0d405b0aa8c60d53278992ca302d4d3400966618d3b0462"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "dd80e58848ec8f7a3034f0d39f9f1ef361032deb68b3c60a5609f70d0483a955"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args(path: "apps/oxlint")
  end

  test do
    (testpath/"test.js").write "const x = 1;"
    output = shell_output("#{bin}/oxlint test.js 2>&1")
    assert_match "eslint(no-unused-vars)::Variable 'x' is declared but never used", output

    assert_match version.to_s, shell_output("#{bin}/oxlint --version")
  end
end
