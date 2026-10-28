class RadDebugger < Formula
  desc "Native, user-mode, multi-process, graphical debugger"
  homepage "https://github.com/EpicGames/raddebugger"
  url "https://github.com/EpicGames/raddebugger.git",
      tag:      "v0.9.29-alpha",
      revision: "cd41ba199bbe091d348a9b2be5a3528cb8acbff0"
  license "MIT"
  head "https://github.com/EpicGames/raddebugger.git", branch: "master"

  depends_on "pkgconf" => :build
  depends_on "freetype"
  depends_on "libx11"
  depends_on "libxext"
  depends_on "libxfixes"
  depends_on "libxrandr"
  depends_on :linux
  depends_on "mesa"

  deny_network_access!

  def install
    # https://github.com/EpicGames/raddebugger/commit/f9eef60935bf1bbd3228b3c137a3b08ec284f260
    inreplace "build.sh", "]] then", "]]; then"

    targets = %w[raddbg raddbg_non_graphical radbin radlink]
    system "./build.sh", "gcc", "release", *targets

    cd "build" do
      bin.install targets
    end
  end

  test do
    system "false"
  end
end
