class RioTerminal < Formula
  desc "Hardware-accelerated GPU terminal emulator powered by WebGPU"
  homepage "https://rioterm.com/"
  url "https://github.com/raphamorim/rio/archive/refs/tags/v0.3.4.tar.gz"
  sha256 "002bacea93139dfa4989efb79968d4103a942ba93dfd95ab7d1e3a4ea53afa6c"
  license "MIT"
  head "https://github.com/raphamorim/rio.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "85abbf5750c936c0f2d52e857041fa670566e8d703920dc3a4adb927b6591f64"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "c37c963227aa36dc90a451dde37056a82a263e637c1301ca6a5f918f23a7fd67"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "e04a8c33d6b9ff6274cc6235bd5a6af6e5ecdcf27accf40b79fd5a140a8b5565"
    sha256 cellar: :any_skip_relocation, sonoma:        "3561a8e4833ee41954fa7e7d4804757d7da3d44363dce8067ecc8be28f018a23"
  end

  depends_on "rust" => :build
  # Rio does work for Linux although it requires a specification of which
  # window manager will be used (x11 or wayland) otherwise will not work.
  depends_on :macos

  conflicts_with "rasterio", because: "both install `rio` binaries"
  conflicts_with cask: "rio", because: "both install `rio` binaries"

  def install
    system "cargo", "install", *std_cargo_args(path: "frontends/rioterm")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/rio --version")

    system bin/"rio", "--write-config", testpath/"rio.toml"
    assert_match "enable-log-file = false", (testpath/"rio.toml").read
  end
end
