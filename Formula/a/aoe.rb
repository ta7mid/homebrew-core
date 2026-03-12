class Aoe < Formula
  desc "Terminal session manager for AI coding agents"
  homepage "https://github.com/njbrake/agent-of-empires"
  url "https://github.com/njbrake/agent-of-empires/archive/refs/tags/v0.16.0.tar.gz"
  sha256 "af136e107fd9a8b009707c2ddcaa1b408feaf6be8276eba0ac899dd555b919f1"
  license "MIT"
  head "https://github.com/njbrake/agent-of-empires.git", branch: "main"

  bottle do
    sha256 cellar: :any,                 arm64_tahoe:   "21cb9555f2c56348c6d7b4df7ee1b96afdb2ec41c8d00713c7e1b720c6def869"
    sha256 cellar: :any,                 arm64_sequoia: "913df596cfed927b29505db1429da60f40ec5fa3642d2c342bf5bf55d2eb9472"
    sha256 cellar: :any,                 arm64_sonoma:  "fcc8d951aeca56aa48fafb8e0a33e28fb88dd71c17b84aa376260f71f3b6398e"
    sha256 cellar: :any,                 sonoma:        "e167b72cc12f7f00b9af43c802d487f282a6e5f19f886a1d0819e13d52b5c632"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "3424c521f829e72372e1d095b0ea495266b75127324a4ac4ae09ae32f2b2b19f"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "1732a873e6c2119e6b09f45c324bdac82bfacfd898e39f8ff327c1a01c990ebe"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "openssl@3"
  depends_on "tmux"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  def install
    system "cargo", "install", *std_cargo_args
    generate_completions_from_executable(bin/"aoe", "completion")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/aoe --version")

    system bin/"aoe", "init", testpath
    assert_match "Agent of Empires", (testpath/".aoe/config.toml").read

    output = shell_output("#{bin}/aoe init #{testpath} 2>&1", 1)
    assert_match "already exists", output

    status = JSON.parse(shell_output("#{bin}/aoe status --json"))
    assert_equal 0, status["total"]
  end
end
