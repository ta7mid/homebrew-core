class Depot < Formula
  desc "Build your Docker images in the cloud"
  homepage "https://depot.dev/"
  url "https://github.com/depot/cli/archive/refs/tags/v2.101.16.tar.gz"
  sha256 "68375808ba990ecc3a7063ab95c1fd0ebf42832fdce4c4943bf07bb7be1a04d7"
  license "MIT"
  head "https://github.com/depot/cli.git", branch: "main"

  # Upstream sometimes creates a tag with a stable version format but does not
  # create a release on GitHub.
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "2477b25c16012fd69564955b28f869fff46b2f59f7e2e05841554e2cca0c0abb"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "2477b25c16012fd69564955b28f869fff46b2f59f7e2e05841554e2cca0c0abb"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "2477b25c16012fd69564955b28f869fff46b2f59f7e2e05841554e2cca0c0abb"
    sha256 cellar: :any_skip_relocation, sonoma:        "44306bc3d3d567bab8260ad3622b60ff25de20f83d7fb348bf0d23d2489203bd"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "12f55d7b1610b8872547cb23877b0518e43ffb31e384f22aa2df0482d7a0d200"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "011e592574a75be346bbc7f85d4378fe1d1efb3a34f60d2091917131deb134b2"
  end

  depends_on "go" => :build

  def install
    ldflags = %W[
      -s -w
      -X github.com/depot/cli/internal/build.Version=#{version}
      -X github.com/depot/cli/internal/build.Date=#{time.iso8601}
      -X github.com/depot/cli/internal/build.SentryEnvironment=release
    ]

    system "go", "build", *std_go_args(ldflags:), "./cmd/depot"

    generate_completions_from_executable(bin/"depot", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/depot --version")
    output = shell_output("#{bin}/depot list builds 2>&1", 1)
    assert_match "Error: unknown project ID", output
  end
end
