class Mumps < Formula
  desc "MUltifrontal Massively Parallel sparse direct Solver"
  homepage "https://mumps-solver.org/"
  url "https://mumps-solver.org/MUMPS_5.8.2.tar.gz"
  sha256 "eb515aa688e6dbab414bb6e889ff4c8b23f1691a843c68da5230a33ac4db7039"
  license all_of: [
    "CECILL-C",
    "BSD-3-Clause", # the parts derived from LAPACK's source code
    :public_domain, # the PORD implementation, copied from SPACE-1.0
  ]

  depends_on "gcc" # for gfortran
  depends_on "metis"
  depends_on "open-mpi"
  depends_on "openblas"
  depends_on "scalapack"
  depends_on "scotch"

  def install
    cp "Make.inc/Makefile.inc.generic", "Makefile.inc"

    metis = Formula["metis"]
    openblas = Formula["openblas"]
    scalapack = Formula["scalapack"]
    scotch = Formula["scotch"]

    makefile_overrides = {
      RPATH_OPT:   "-Wl,-rpath,#{rpath}",
      CC:          "mpicc",
      FC:          "mpifort",
      FL:          "$(FC)",
      OPTC:        "-O3",
      OPTF:        "$(OPTC) -fallow-argument-mismatch", # fix for GCC 10+: https://mumps-solver.org/index.php?page=faq#2.12
      OPTL:        "$(OPTF)",

      ORDERINGSF:  "-Dmetis -Dpord -Dscotch -Dptscotch",
      IORDERINGSF: "-I#{scotch.include}",
      IORDERINGSC: "-I#{metis.include} $(IPORD) -I#{scotch.include}",
      LORDERINGS:  %W[
        -L#{metis.lib} -L#{scotch.lib}
        -lmetis $(LPORD) -lptesmumps -lptscotch -lptscotcherr -lscotch
      ].join(" "),

      INCS:        "", # Let MPI compilers fill in the blanks
      LIBS:        "-L#{scalapack.lib} -L#{openblas.lib} -lscalapack -llapack",
      LIBBLAS:     "-L#{openblas.lib} -lopenblas",
    }

    if OS.mac?
      makefile_overrides.update({
        LIBEXT_SHARED: ".dylib",
        SONAME:        "-install_name",
      })
    end

    (buildpath/"Makefile.inc").append_lines <<~EOS
      # Overrides for Homebrew build
      #{makefile_overrides.map { |k, v| "#{k}=#{v}" }.join("\n")}
    EOS

    # Override mpifort's -flat_namespace flag
    ENV["OMPI_LDFLAGS"] = "-Wl,-twolevel_namespace" if OS.mac?

    system "make", "allshared"

    # The Makefile doesn't provide install targets
    include.install Dir["include/*"] - ["mpif.h"]
    lib.install Dir["lib/#{shared_library("*")}"]

    # Install docs and examples
    doc.install Dir["doc/*.pdf"]
    cd "examples" do
      system "make", "clean" # remove binaries
      inreplace "Makefile" do |s|
        s.change_make_var! "topdir", prefix
        s.gsub! "-I$(topdir)/src ", "" # fix warnings about non-existent dir
      end
    end
    pkgshare.install "examples"

    # Needed by the examples Makefile and useful as a build record
    prefix.install "Makefile.inc"
  end

  test do
    cp Dir[pkgshare/"examples/*"], testpath
    system "make", "all"
    system "./ssimpletest <input_simpletest_real"
    system "./dsimpletest <input_simpletest_real"
    system "./csimpletest <input_simpletest_cmplx"
    system "./zsimpletest <input_simpletest_cmplx"
    system "./c_example"
    system "./multiple_arithmetics_example"
    system "./ssimpletest_save_restore <input_simpletest_real"
    system "./dsimpletest_save_restore <input_simpletest_real"
    system "./csimpletest_save_restore <input_simpletest_cmplx"
    system "./zsimpletest_save_restore <input_simpletest_cmplx"
    system "./c_example_save_restore"
  end
end
