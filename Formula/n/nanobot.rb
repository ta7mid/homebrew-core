class Nanobot < Formula
  desc "Build MCP Agents"
  homepage "https://www.nanobot.ai/"
  url "https://github.com/nanobot-ai/nanobot/archive/refs/tags/v0.0.62.tar.gz"
  sha256 "95ddf48cd35dae949952cd490eb7858e581a7ead2c87f0e041f34347cc9c4080"
  license "Apache-2.0"
  head "https://github.com/nanobot-ai/nanobot.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "43194fd58a02c3f177b8989d349c2157414a76626452b797b3eb164f5a2d418e"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "761123a58379dc8fddfceb7f4b5981d3243e1117dafde9ca8f0eff21319ef353"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "f9f7acdc094a936d4bbe6f29286c3fa820690235941a9b40aa3885ca28415cfb"
    sha256 cellar: :any_skip_relocation, sonoma:        "0cd5ab57d053cb3c40f8f54e87d7a3b4bd0df83f0ab7401d9663e22d7e7650da"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "a4793fc6c0682b95fe0456eed21e26fb1e5cfdb9c3ace091104fc60ca4eb98bb"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "44e9a053eed6dcadfc686fb001a462804b657471de2ef2ad5815ed181fd997cb"
  end

  depends_on "go" => :build

  def install
    ldflags = %W[
      -s -w
      -X github.com/nanobot-ai/nanobot/pkg/version.Tag=v#{version}
      -X github.com/nanobot-ai/nanobot/pkg/version.BaseImage=ghcr.io/nanobot-ai/nanobot:v#{version}
    ]
    system "go", "build", *std_go_args(ldflags:)

    generate_completions_from_executable(bin/"nanobot", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/nanobot --version")

    pid = spawn bin/"nanobot", "run"
    sleep 1
    assert_path_exists testpath/"nanobot.db"
  ensure
    Process.kill("TERM", pid)
    Process.wait(pid)
  end
end
