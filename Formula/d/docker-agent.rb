class DockerAgent < Formula
  desc "Agent Builder and Runtime by Docker Engineering"
  homepage "https://docker.github.io/docker-agent/"
  url "https://github.com/docker/docker-agent/archive/refs/tags/v1.32.1.tar.gz"
  sha256 "1aa89904daf3572c4c869b23291b6c318a3d78d6367bf552c5825fa22a5c90e1"
  license "Apache-2.0"
  head "https://github.com/docker/docker-agent.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "9220dc33352f031b26ba49f8b314b7164869f6079675f3678c71aed039a3b50c"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "1c4b4941adeffb8eb1a3ed1b674e8d18c161d6721d6a405a1b248d0d0f4ea627"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "4c2dea652ee38ab7bbe4dfd77c1147c8d8149eeaad36ffb4ade48699144c62cf"
    sha256 cellar: :any_skip_relocation, sonoma:        "25475e3897a0c1e3a7d79e0cd84da4a3d724e057541563760efd96138f7ab7f8"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "33a8b3a00a051ab3024668fc2c814c19b88616e6fb2b77a2ba0b208a4885d072"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "493ae94adc334dbf555cbf4ae053560bfb11662564149b70fe781c8422a32249"
  end

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "1" if OS.linux? && Hardware::CPU.arm?

    ldflags = %W[
      -s -w
      -X github.com/docker/docker-agent/pkg/version.Version=v#{version}
      -X github.com/docker/docker-agent/pkg/version.Commit=#{tap.user}
    ]

    system "go", "build", *std_go_args(ldflags:)

    generate_completions_from_executable(bin/"docker-agent", shell_parameter_format: :cobra)
  end

  test do
    (testpath/"agent.yaml").write <<~YAML
      version: "2"
      agents:
        root:
          model: openai/gpt-4o
    YAML

    assert_match("docker-agent version v#{version}", shell_output("#{bin}/docker-agent version"))
    output = shell_output("#{bin}/docker-agent run --exec --dry-run agent.yaml hello 2>&1", 1)
    assert_match(/must be set.*OPENAI_API_KEY/m, output)
  end
end
