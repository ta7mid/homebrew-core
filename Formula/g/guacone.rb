class Guacone < Formula
  desc "Command-line interface for GUAC"
  homepage "https://guac.sh/guac/"
  url "https://github.com/guacsec/guac/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "29fdb33d49c3b18849a9ad6fcc130d3557995994d9e612acb86aea808afc136b"
  license "Apache-2.0"
  head "https://github.com/guacsec/guac.git", branch: "main"

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "0"
    ldflags = %W[
      -s -w
      -X github.com/guacsec/guac/pkg/version.Date=#{time.iso8601}
      -X github.com/guacsec/guac/pkg/version.Version=#{version}
    ]
    system "go", "build", *std_go_args(ldflags:), "./cmd/guacone"

    generate_completions_from_executable bin/"guacone", shell_parameter_format: :cobra
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/guacone --version")
  end
end
