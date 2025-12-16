class ReflectCpp < Formula
  desc "Fast serialization, deserialization and validation in C++20 using reflection"
  homepage "https://rfl.getml.com"
  url "https://github.com/getml/reflect-cpp/archive/refs/tags/v0.22.0.tar.gz"
  sha256 "5756d74e7df640b4633a3ea5a3c0d7c4e096bdd3f67828f8b02f58b156ba39ec"
  license "MIT"

  depends_on "cmake" => :build
  depends_on "apache-arrow"
  depends_on "capnp"
  depends_on "ctre"
  depends_on "flatbuffers"
  depends_on "mongo-c-driver"
  depends_on "msgpack"
  depends_on "pugixml"
  depends_on "tomlplusplus"
  depends_on "yaml-cpp"
  depends_on "yyjson"

  def install
    inreplace "CMakeLists.txt" do |s|
      s.gsub! "bson-1.0", "bson"
      s.gsub! "$<IF:$<TARGET_EXISTS:mongo::bson_static>,mongo::bson_static,mongo::bson_shared>", "bson::shared"
      s.gsub! "arrow::arrow", "Arrow::arrow_shared"
    end
    inreplace "reflectcpp-config.cmake.in", "bson-1.0", "bson"

    args = %w[
      -DBUILD_SHARED_LIBS=ON
      -DCMAKE_CXX_STANDARD=20
      -DREFLECTCPP_ALL_FORMATS=ON
      -DREFLECTCPP_AVRO=OFF
      -DREFLECTCPP_CBOR=OFF
      -DREFLECTCPP_UBJSON=OFF
      -DREFLECTCPP_USE_BUNDLED_DEPENDENCIES=OFF
      -DREFLECTCPP_USE_VCPKG=OFF
    ]
    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cxx").write <<~CPP
      #include <rfl/json/read.hpp>
      #include <rfl/json/write.hpp>
      #include <cassert>
      #include <iostream>
      #include <string>

      int main()
      {
        struct Person {
          std::string name;
          int age;
        };

        const std::string json = rfl::json::write(Person{
          .name = "Homer",
          .age = 45
        });

        const auto homer = rfl::json::read<Person>(json).value();
        assert(homer.age == 45);
        std::cout << homer.name;
      }
    CPP

    yyjson = Formula["yyjson"]
    system ENV.cxx, "test.cxx", "-o", "test", "-std=c++20",
      "-I#{include}", "-I#{yyjson.include}",
      "-L#{lib}", "-L#{yyjson.lib}",
      "-lreflectcpp", "-lyyjson"

    assert_equal "Homer", shell_output("./test")
  end
end
