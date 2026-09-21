class Perlbrew < Formula
  desc "Manage perl installations in your $HOME"
  homepage "https://perlbrew.pl/"
  url "https://cpan.metacpan.org/authors/id/G/GU/GUGOD/App-perlbrew-1.02.tar.gz"
  sha256 "24064b227481737b65d95e2dab5b677b90c720f8e9a19d28b2152728617c24ed"
  license "MIT"
  head "https://github.com/gugod/App-perlbrew.git", branch: "develop"

  uses_from_macos "perl"

  resource "CPAN::Perl::Releases" do
    url "https://cpan.metacpan.org/authors/id/B/BI/BINGOS/CPAN-Perl-Releases-5.20260820.tar.gz"
    sha256 "fb5379663d117d35536f1c986ee978d221548c1b58a53748fd4769d2a7a42a56"
  end

  resource "Capture::Tiny" do
    url "https://cpan.metacpan.org/authors/id/D/DA/DAGOLDEN/Capture-Tiny-0.50.tar.gz"
    sha256 "ca6e8d7ce7471c2be54e1009f64c367d7ee233a2894cacf52ebe6f53b04e81e5"
  end

  resource "Devel::PatchPerl" do
    url "https://cpan.metacpan.org/authors/id/B/BI/BINGOS/Devel-PatchPerl-2.14.tar.gz"
    sha256 "2426d27ab00f65ecded5cdc8f2c2889b01c199063ab4ab688fc8df39cdde9a0f"
  end

  resource "ExtUtils::Config" do
    url "https://cpan.metacpan.org/authors/id/L/LE/LEONT/ExtUtils-Config-0.010.tar.gz"
    sha256 "82e7e4e90cbe380e152f5de6e3e403746982d502dd30197a123652e46610c66d"
  end

  resource "ExtUtils::Helpers" do
    url "https://cpan.metacpan.org/authors/id/L/LE/LEONT/ExtUtils-Helpers-0.028.tar.gz"
    sha256 "c8574875cce073e7dc5345a7b06d502e52044d68894f9160203fcaab379514fe"
  end

  resource "ExtUtils::InstallPaths" do
    url "https://cpan.metacpan.org/authors/id/L/LE/LEONT/ExtUtils-InstallPaths-0.015.tar.gz"
    sha256 "7d64eb2dfa87ead010cdf55c8a1bdfde50b7b5852d7cb8cf2304f55bea2eb007"
  end

  resource "File::pushd" do
    url "https://cpan.metacpan.org/authors/id/D/DA/DAGOLDEN/File-pushd-1.016.tar.gz"
    sha256 "d73a7f09442983b098260df3df7a832a5f660773a313ca273fa8b56665f97cdc"
  end

  resource "Module::Build::Tiny" do
    url "https://cpan.metacpan.org/authors/id/L/LE/LEONT/Module-Build-Tiny-0.053.tar.gz"
    sha256 "3726d622da6f655e88fdf89e4fd597709c44970b47de65082003e8d86b5e193a"
  end

  resource "Module::Pluggable" do
    url "https://cpan.metacpan.org/authors/id/S/SI/SIMONW/Module-Pluggable-6.4.tar.gz"
    sha256 "970fd13accd3d538e637db080ebbd9898020c8b5591837c8493a39edd737922d"
  end

  resource "local::lib" do
    url "https://cpan.metacpan.org/authors/id/H/HA/HAARG/local-lib-2.000029.tar.gz"
    sha256 "8df87a10c14c8e909c5b47c5701e4b8187d519e5251e87c80709b02bb33efdd7"
  end

  deny_network_access!

  def install
    ENV.prepend_create_path "PERL5LIB", libexec/"lib/perl5"

    resources.each do |r|
      r.stage do
        if File.exist? "Build.PL"
          system "perl", "Build.PL", "--install_base", libexec
          system "./Build"
          system "./Build", "install"
        else
          system "perl", "Makefile.PL", "INSTALL_BASE=#{libexec}"
          system "make", "install"
        end
      end
    end

    system "perl", "Build.PL", "--install_base", libexec,
           "--install_path", "bindoc=#{man1}", "--install_path", "libdoc=#{man3}"
    system "./Build"
    system "./Build", "install"

    # perlbrew looks for a `patchperl` executable on PATH, which the
    # Devel::PatchPerl resource installs into libexec.
    (bin/"perlbrew").write_env_script libexec/"bin/perlbrew",
                                      PATH:     "#{libexec}/bin:$PATH",
                                      PERL5LIB: ENV["PERL5LIB"]
  end

  test do
    ENV["PERLBREW_ROOT"] = testpath/"perlbrew"
    ENV["PERLBREW_HOME"] = testpath/"perlbrew-home"

    assert_match version.to_s, shell_output("#{bin}/perlbrew version")

    system bin/"perlbrew", "init"
    assert_match "export PERLBREW_ROOT=#{testpath}/perlbrew",
                 (testpath/"perlbrew/etc/bashrc").read

    # Building a perl needs the network, so point an installation directory
    # at the perl we depend on to exercise installation discovery.
    (testpath/"perlbrew/perls/perl-test/bin").mkpath
    ln_s formula_opt_bin("perl")/"perl", testpath/"perlbrew/perls/perl-test/bin/perl"
    assert_match "perl-test", shell_output("#{bin}/perlbrew list")

    system bin/"perlbrew", "lib", "create", "perl-test@demo"
    assert_match "perl-test@demo", shell_output("#{bin}/perlbrew lib list")
  end
end
