class CanonicalChisel < Formula
  desc "Tool for carving and cutting Debian packages"
  homepage "https://github.com/canonical/chisel"
  url "https://github.com/canonical/chisel/archive/refs/tags/v1.4.2.tar.gz"
  sha256 "024b5d92b675153c779dcf6c1c75854b9c118043b6fbdd854a0d50af4408b454"
  license "AGPL-3.0-or-later"
  head "https://github.com/canonical/chisel.git", branch: "main"

  depends_on "go" => :build
  depends_on :linux

  conflicts_with "chisel", because: "both install `chisel` binaries"
  conflicts_with "chisel-tunnel", because: "both install `chisel` binaries"
  conflicts_with "foundry", because: "both install `chisel` binaries"

  def install
    ENV["CGO_ENABLED"] = "0"
    system "cmd/mkversion.sh", version
    system "go", "build", *std_go_args(output: bin/"chisel"), "./cmd/chisel"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/chisel version").strip
  end
end
