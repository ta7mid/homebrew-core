class Zed < Formula
  desc "Multiplayer code editor from the creators of Atom and Tree-sitter"
  homepage "https://zed.dev"
  url "https://github.com/zed-industries/zed/archive/refs/tags/v1.19.2.tar.gz"
  sha256 "4f5ee171225f659b5e2a479549321301a4e0749e926c46953d48f600f81007a7"
  license all_of: ["GPL-3.0-or-later", "Apache-2.0"]
  head "https://github.com/zed-industries/zed.git", branch: "main"

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", "--locked", "--target", "host-tuple"
  end

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/zed")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/zed --version")
  end
end
