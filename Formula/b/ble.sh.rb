class BleSh < Formula
  desc "Bash Line Editor: syntax highlighting, enhanced autocomplete, Vim mode, etc."
  homepage "https://github.com/akinomyoga/ble.sh"
  url "https://github.com/akinomyoga/ble.sh.git",
      tag:      "v0.4.0-devel3",
      revision: "1a5c451c8baa71439a6be4ea0f92750de35a7620"
  version "0.4.0-devel3"
  license "BSD-3-Clause"
  head "https://github.com/akinomyoga/ble.sh.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+(?:-devel\d+)?)$/i) # allows a "-develN" suffix
    strategy :github_latest
  end

  depends_on "gawk" => :build

  on_macos do
    depends_on "bash"
  end

  def install
    vars = %W[
      PREFIX=#{prefix}
      INSDIR_LICENSE=#{prefix}
    ]
    ENV.deparallelize # to address https://github.com/akinomyoga/ble.sh/issues/689
    system "make", *vars, "install"

    cd share/"doc/blesh" do
      prefix.install_metafiles
    end
    rm_r share/"doc"
  end

  def caveats
    <<~EOS
      The ble.sh script is installed as
        #{HOMEBREW_PREFIX/"share/blesh/ble.sh"}
    EOS
  end

  test do
    system "bash", share/"blesh/ble.sh", "--help"

    # In absence of $HOME/.cache, `ble.sh --lib` tries and fails to create files
    # in #{share}/blesh/cache.d, which is outside of the test sandbox.
    (testpath/".cache").mkdir
    system "bash", share/"blesh/ble.sh", "--lib"
  end
end
