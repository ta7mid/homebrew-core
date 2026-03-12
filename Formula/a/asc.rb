class Asc < Formula
  desc "Fast, lightweight CLI for App Store Connect"
  homepage "https://asccli.sh"
  url "https://github.com/rudrankriyam/App-Store-Connect-CLI/archive/refs/tags/0.40.0.tar.gz"
  sha256 "21d451ad289c4635b492b6c1ac18923cabed42384d0693c1975e0d1b1522fbf8"
  license "MIT"
  head "https://github.com/rudrankriyam/App-Store-Connect-CLI.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "7a65a4f78705197e7493fecb4cc120e7595de5aaeb286c2504f323a7ee99d6e7"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "405ec81338eb4a062b506cec2d69052e075a7cab103b13de4d645c0a7e2b329a"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "f4e1fc31b0d71e1c6d29dfe3427a827c21b575adc25b914b4074e38718b79d1d"
    sha256 cellar: :any_skip_relocation, sonoma:        "8fceb8657b4f32bafe69b031f52a59923e04e9e2cce7570d69b0beb44d03a7ca"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "c6ab7b7fa1454c60cd44a99d9219b426226d1a9b34bfc940061f8c105dd8b269"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "b733b487b9f9baf3dfaaa3f84c01ebc99037bdc89336be658bcc7821feefee60"
  end

  depends_on "go" => :build

  def install
    ldflags = "-s -w -X main.version=#{version}"
    system "go", "build", *std_go_args(ldflags:)

    generate_completions_from_executable(bin/"asc", "completion", "--shell")
  end

  test do
    system bin/"asc", "init", "--path", testpath/"ASC.md", "--link=false"
    assert_path_exists testpath/"ASC.md"
    assert_match "asc cli reference", (testpath/"ASC.md").read
    assert_match version.to_s, shell_output("#{bin}/asc version")
  end
end
