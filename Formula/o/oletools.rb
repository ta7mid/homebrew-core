class Oletools < Formula
  include Language::Python::Virtualenv

  desc "Analyse MS Office and OLE2 files for malware analysis and forensics"
  homepage "https://github.com/decalage2/oletools"
  url "https://files.pythonhosted.org/packages/5c/2f/037f40e44706d542b94a2312ccc33ee2701ebfc9a83b46b55263d49ce55a/oletools-0.60.2.zip"
  sha256 "ad452099f4695ffd8855113f453348200d195ee9fa341a09e197d66ee7e0b2c3"
  license "BSD-2-Clause"
  head "https://github.com/decalage2/oletools.git", branch: "master"

  depends_on "cryptography" => :no_linkage
  depends_on "python@3.14"

  pypi_packages exclude_packages: ["cryptography"]

  resource "colorclass" do
    url "https://files.pythonhosted.org/packages/d7/1a/31ff00a33569a3b59d65bbdc445c73e12f92ad28195b7ace299f68b9af70/colorclass-2.2.2.tar.gz"
    sha256 "6d4fe287766166a98ca7bc6f6312daf04a0481b1eda43e7173484051c0ab4366"
  end

  resource "easygui" do
    url "https://files.pythonhosted.org/packages/cc/ad/e35f7a30272d322be09dc98592d2f55d27cc933a7fde8baccbbeb2bd9409/easygui-0.98.3.tar.gz"
    sha256 "d653ff79ee1f42f63b5a090f2f98ce02335d86ad8963b3ce2661805cafe99a04"
  end

  resource "msoffcrypto-tool" do
    url "https://files.pythonhosted.org/packages/a6/34/6250bdddaeaae24098e45449ea362fb3555a65fba30cad0ad5630ea48d1a/msoffcrypto_tool-6.0.0.tar.gz"
    sha256 "9a5ebc4c0096b42e5d7ebc2350afdc92dc511061e935ca188468094fdd032bbe"
  end

  resource "olefile" do
    url "https://files.pythonhosted.org/packages/69/1b/077b508e3e500e1629d366249c3ccb32f95e50258b231705c09e3c7a4366/olefile-0.47.zip"
    sha256 "599383381a0bf3dfbd932ca0ca6515acd174ed48870cbf7fee123d698c192c1c"
  end

  resource "pcodedmp" do
    url "https://files.pythonhosted.org/packages/3d/20/6d461e29135f474408d0d7f95b2456a9ba245560768ee51b788af10f7429/pcodedmp-1.2.6.tar.gz"
    sha256 "025f8c809a126f45a082ffa820893e6a8d990d9d7ddb68694b5a9f0a6dbcd955"
  end

  resource "pyparsing" do
    url "https://files.pythonhosted.org/packages/f3/91/9c6ee907786a473bf81c5f53cf703ba0957b23ab84c264080fb5a450416f/pyparsing-3.3.2.tar.gz"
    sha256 "c777f4d763f140633dcb6d8a3eda953bf7a214dc4eff598413c070bcdc117cbc"
  end

  def install
    venv = virtualenv_install_with_resources without: "colorclass"

    # Switch build-system to poetry-core to avoid rust dependency on Linux.
    # Remove when released: https://github.com/matthewdeanmartin/colorclass/pull/2
    resource("colorclass").stage do
      inreplace "pyproject.toml", 'requires = ["poetry>=0.12"]', 'requires = ["poetry-core>=1.0"]'
      inreplace "pyproject.toml", 'build-backend = "poetry.masonry.api"', 'build-backend = "poetry.core.masonry.api"'
      venv.pip_install Pathname.pwd
    end
  end

  test do
    # Minimal OLE2/CFB container: header, one FAT sector and a directory holding only the root entry
    end_of_chain = 0xFFFFFFFE
    header = [0xD0, 0xCF, 0x11, 0xE0, 0xA1, 0xB1, 0x1A, 0xE1].pack("C*") + ("\0" * 16) +
             [0x3E, 3, 0xFFFE, 9, 6].pack("v5") + ("\0" * 6) +
             [0, 1, 1, 0, 0x1000, end_of_chain, 0, end_of_chain, 0, 0].pack("V10") + ([0xFFFFFFFF] * 108).pack("V*")
    fat = ([0xFFFFFFFD, end_of_chain] + ([0xFFFFFFFF] * 126)).pack("V*")
    root = "Root Entry".encode("UTF-16LE").b.ljust(64, "\0") +
           [22, 5, 1, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF].pack("vCCV3") + ("\0" * 36) + [end_of_chain, 0].pack("VQ<")
    (testpath/"test.ole").binwrite(header + fat + root.ljust(512, "\0"))
    assert_match "Container format    |OLE", shell_output("#{bin}/oleid #{testpath}/test.ole")
    assert_match "Root Entry", shell_output("#{bin}/oledir #{testpath}/test.ole")

    # RTF with an embedded OLE 1.0 Package object carrying payload.txt
    content = "hello from homebrew\n"
    package = [2].pack("v") + "payload.txt\0C:\\payload.txt\0" + [0, 3].pack("V2") + "C:\\Temp\\payload.txt\0" +
              [content.bytesize].pack("V") + content
    ole_object = [0x501, 2, 8].pack("V3") + "Package\0" + [0, 0, package.bytesize].pack("V3") + package
    (testpath/"test.rtf").write "{\\rtf1{\\object\\objemb{\\*\\objdata #{ole_object.unpack1("H*")}}}}"
    output = shell_output("#{bin}/rtfobj #{testpath}/test.rtf")
    assert_match "OLE Package object", output
    assert_match "Filename: 'payload.txt'", output

    (testpath/"macro.vba").write <<~VBA
      Sub AutoOpen()
          Shell "cmd.exe /c calc.exe"
      End Sub
    VBA
    output = shell_output("#{bin}/olevba #{testpath}/macro.vba")
    assert_match "olevba #{version}", output
    assert_match "|AutoExec  |AutoOpen", output
    assert_match "|Suspicious|Shell", output
    assert_match "SUSPICIOUS|A-X", shell_output("#{bin}/mraptor #{testpath}/macro.vba", 20)
  end
end
