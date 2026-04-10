class Fence < Formula
  desc "Lightweight sandbox for commands with network and filesystem restrictions"
  homepage "https://github.com/Use-Tusk/fence"
  url "https://github.com/Use-Tusk/fence/archive/refs/tags/v0.1.43.tar.gz"
  sha256 "aa3ba1e3607fac529191b34849c4840b268c87330c0cced06dc3a7ee9aa2d9a7"
  license "Apache-2.0"
  head "https://github.com/Use-Tusk/fence.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "629b7647819bbfa0dc4cfd21fa379db80d612d2f1c85a5b8616f2c737e71a551"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "629b7647819bbfa0dc4cfd21fa379db80d612d2f1c85a5b8616f2c737e71a551"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "629b7647819bbfa0dc4cfd21fa379db80d612d2f1c85a5b8616f2c737e71a551"
    sha256 cellar: :any_skip_relocation, sonoma:        "268307ac60749be1cb0685bed1bd346709ae49c41093423b78fff271d45f02dc"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "c8a0f5355844dd1f9dc5597eb827f16e9a53c0aaf90894c255e6f1d5dba55dd9"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "3faa29ea1f8d1fde9373c80ac27494aa5a6358be6995ea453c6a745efe6cc875"
  end

  depends_on "go" => :build

  on_linux do
    depends_on "bubblewrap" => :no_linkage
    depends_on "socat" => :no_linkage
  end

  def install
    ldflags = %W[
      -s -w
      -X main.version=#{version}
      -X main.buildTime=#{time.iso8601}
      -X main.gitCommit=#{tap.user}
    ]
    system "go", "build", *std_go_args(ldflags:), "./cmd/fence"

    generate_completions_from_executable(bin/"fence", "completion", shells: [:bash, :zsh, :fish, :pwsh])
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/fence --version")

    # General functionality cannot be tested in CI due to sandboxing,
    # but we can test that config import works.
    (testpath/".claude/settings.json").write <<~JSON
      {}
    JSON
    system bin/"fence", "import", "--claude", "-o", testpath/".fence.json"
    assert_path_exists testpath/".fence.json"
  end
end
