class FlowCli < Formula
  desc "Command-line interface that provides utilities for building Flow applications"
  homepage "https://onflow.org"
  url "https://github.com/onflow/flow-cli/archive/refs/tags/v2.15.0.tar.gz"
  sha256 "079ad60a0bae0dd937c2fc1111a8e650aff2ea709e76cce5e6bd85e6dbe1d327"
  license "Apache-2.0"
  head "https://github.com/onflow/flow-cli.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "027febf03edef23125e936dd6faa4619831d09a4956cc6e2c3227a926eedc96c"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "a75791bbd9168c39261113d27a531b83137f5104dad0f66d50a32839b7990696"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "36dfa8506b162d168a430895b98b4c1057c689caef557d63114e5aff504e9200"
    sha256 cellar: :any_skip_relocation, sonoma:        "812d2621bf94a09caf857d543d8874f50975958f11a230446a4168235f151862"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "bd5f91ef3f9fb7234ac256dc241435546a986e2abdfca73416747094cd981714"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "8870e5e0deeac62ca2708fab97b7ca18ba6bc053e0e4cf154b399bd71961158d"
  end

  depends_on "go@1.25" => :build

  conflicts_with "flow", because: "both install `flow` binaries"

  def install
    ENV["CGO_ENABLED"] = "1" if OS.linux? && Hardware::CPU.arm?

    ldflags = %W[
      -s -w
      -X github.com/onflow/flow-cli/build.semver=v#{version}
      -X github.com/onflow/flow-cli/build.commit=homebrew
    ]
    system "go", "build", *std_go_args(ldflags:, output: bin/"flow"), "./cmd/flow"

    generate_completions_from_executable(bin/"flow", shell_parameter_format: :cobra)
  end

  test do
    (testpath/"hello.cdc").write <<~EOS
      access(all) fun main() {
        log("Hello, world!")
      }
    EOS

    system bin/"flow", "cadence", "hello.cdc"
  end
end
