class GoSizeAnalyzer < Formula
  desc "Analyzing the dependencies in compiled Golang binaries"
  homepage "https://github.com/Zxilly/go-size-analyzer"
  url "https://github.com/Zxilly/go-size-analyzer/archive/refs/tags/v1.12.1.tar.gz"
  sha256 "fed686cabe044bb42737cd2c72d01d8d075ee8b5ca0c7384ed0ce2234e0fefa8"
  license "AGPL-3.0-only"
  head "https://github.com/Zxilly/go-size-analyzer.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "37b107f6971393940870af3ad4144336fd582461b16aa22060ad239ca38a7cda"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "2696cec40e15dcc98138bb3afe1afbf3b3deaed0d4ff82c64783da2f47d3aea5"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "c2a5a11f3d1ed1c55e1bc60581f687b18bb132d7604b30738ccdc037cc1f3ac7"
    sha256 cellar: :any_skip_relocation, sonoma:        "9991aefdc160cd7fcf79e198a225acbc602f01846ffe9336ca976b7fe170f0f9"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "398fd87304daad0b699b5cd5385c35372325666c1265ca4237c0b61e1fa592cc"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "ce3df7e8e8ca50bb4b77ebd99a47c4dc5edef70687c07ea53cfb3c18cd292038"
  end

  depends_on "go" => [:build, :test]
  depends_on "node" => :build
  depends_on "pnpm" => :build

  conflicts_with "gwenhywfar", because: "both install `gsa` binaries"

  def install
    system "pnpm", "--dir", "ui", "install"
    system "pnpm", "--dir", "ui", "build:ui"

    mv "ui/dist/webui/index.html", "internal/webui/index.html"

    ldflags = %W[
      -s -w
      -X github.com/Zxilly/go-size-analyzer.version=#{version}
      -X github.com/Zxilly/go-size-analyzer.buildDate=#{Time.now.iso8601}
      -X github.com/Zxilly/go-size-analyzer.dirtyBuild=false
    ]

    system "go", "build", *std_go_args(ldflags:, tags: "embed", output: bin/"gsa"), "./cmd/gsa"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/gsa --version")

    (testpath/"hello.go").write <<~GO
      package main

      func main() {
        println("Hello, World")
      }
    GO

    system "go", "build", testpath/"hello.go"

    output = shell_output("#{bin}/gsa #{testpath}/hello 2>&1")
    assert_match "runtime", output
    assert_match "main", output
  end
end
