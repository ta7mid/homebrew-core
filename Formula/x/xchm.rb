class Xchm < Formula
  desc "Compiled HTML Help (CHM) file viewer built on chmlib"
  homepage "https://github.com/rzvncj/xCHM"
  url "https://github.com/rzvncj/xCHM/releases/download/1.40/xchm-1.40.tar.gz"
  sha256 "f78c1d48edb2c6d6985850ea7ba8529248278a0ac28c3a988816afbbd6698115"
  license "GPL-2.0-or-later"
  head do
    url "https://github.com/rzvncj/xCHM.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  depends_on "gettext" => :build
  depends_on "wxwidgets@3.2"

  on_linux do
    depends_on "xorg-server" => :test
  end

  deny_network_access!

  def install
    # Add aarch64 to the bundled chmlib's 64-bit platform list, as the `chmlib` formula does.
    # Upstream report: https://github.com/rzvncj/xCHM/issues/34
    inreplace "src/chm_lib.c", "#elif __x86_64__ || __ia64__", "\\0 || __aarch64__"

    system "autoreconf", "--force", "--install", "--verbose" if build.head?
    system "./configure", "--disable-silent-rules",
                          "--enable-builtin-chmlib",
                          "--with-wx-config=#{formula_opt_bin("wxwidgets@3.2")/"wx-config-3.2"}",
                          *std_configure_args
    system "make", "install"
  end

  test do
    # Cannot run any useful test within macOS sandbox
    xchm = bin/"xchm"
    assert_path_exists xchm
    return if OS.mac?

    IO.pipe do |read_io, write_io|
      pid = spawn(formula_opt_bin("xorg-server")/"Xvfb", "-displayfd", write_io.fileno.to_s, write_io => write_io)
      write_io.close
      ENV["DISPLAY"] = ":#{read_io.read.strip}"
      assert_match "Usage: xchm [-c <num>]", shell_output("#{xchm} --help 2>&1", 255)
      assert_match "Unknown long option 'bogus'", shell_output("#{xchm} --bogus 2>&1", 255)
      # A context ID without a file is rejected by xchm itself rather than by the wxWidgets option parser
      assert_match "requires that a file be specified", shell_output("#{xchm} --contextid=1 2>&1", 255)
    ensure
      if pid
        Process.kill "TERM", pid
        Process.wait pid
      end
    end
  end
end
