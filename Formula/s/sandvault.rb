class Sandvault < Formula
  desc "Run AI agents isolated in a sandboxed macOS user account"
  homepage "https://github.com/webcoyote/sandvault"
  url "https://github.com/webcoyote/sandvault/archive/refs/tags/v1.1.34.tar.gz"
  sha256 "952eb0d27f815445ac744d595b2e81d468e5af3b21b1355a72f65326a249abfa"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "d69e66a6dc111c35c5c2f7eef88795f35681f2414768b99f33f48225c01c0f80"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "d69e66a6dc111c35c5c2f7eef88795f35681f2414768b99f33f48225c01c0f80"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "d69e66a6dc111c35c5c2f7eef88795f35681f2414768b99f33f48225c01c0f80"
    sha256 cellar: :any_skip_relocation, sonoma:        "0ed0889da51d80edfdcecaebb823bfd6d607f59cde5b19f60a6eb23aaa3bdf3b"
  end

  depends_on :macos

  conflicts_with "runit", because: "both install `sv` binaries"

  def install
    prefix.install "guest", "sv"
    bin.write_exec_script "#{prefix}/sv"
  end

  test do
    assert_equal "sv version #{version}", shell_output("#{bin}/sv --version").chomp
  end
end
