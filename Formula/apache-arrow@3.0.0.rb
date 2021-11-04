class ApacheArrowAT300 < Formula
  desc "Columnar in-memory analytics layer designed to accelerate big data"
  homepage "https://arrow.apache.org/"
  url "https://www.apache.org/dyn/closer.lua?path=arrow/arrow-3.0.0/apache-arrow-3.0.0.tar.gz"
  mirror "https://archive.apache.org/dist/arrow/arrow-3.0.0/apache-arrow-3.0.0.tar.gz"
  sha256 "73c2cc3be537aa1f3fd9490cfec185714168c9bfd599d23e287ab0cc0558e27a"
  license "Apache-2.0"
  revision 4
  head "https://github.com/apache/arrow.git"

  depends_on "boost" => :build
  depends_on "cmake" => :build
  depends_on "llvm" => :build
  depends_on "brotli"
  depends_on "glog"
  depends_on "grpc"
  depends_on "lz4"
  depends_on "numpy"
  depends_on "openssl@1.1"
  depends_on "protobuf"
  depends_on "python@3.9"
  depends_on "rapidjson"
  depends_on "re2"
  depends_on "snappy"
  depends_on "thrift"
  depends_on "zstd"

  # Remove in next version
  # https://github.com/apache/arrow/pull/9542
  patch do
    url "https://github.com/apache/arrow/commit/06c795c948b594c16d3a48289519ce036a285aad.patch?full_index=1"
    sha256 "732845543b67289d1d462ebf6e87117ac72104047c6747e189a76d09840bc23f"
  end

  def install
    # link against system libc++ instead of llvm provided libc++
    ENV.remove "HOMEBREW_LIBRARY_PATHS", Formula["llvm"].opt_lib
    args = %W[
      -DCMAKE_FIND_PACKAGE_PREFER_CONFIG=TRUE
      -DARROW_FILESYSTEM=ON
      -DARROW_FLIGHT=ON
      -DARROW_GANDIVA=ON
      -DARROW_JEMALLOC=ON
      -DARROW_JSON=ON
      -DARROW_CSV=ON
      -DARROW_COMPUTE=ON
      -DARROW_DATASET=ON
      -DARROW_MIMALLOC=OFF
      -DARROW_ORC=ON
      -DARROW_PARQUET=ON
      -DPARQUET_BUILD_EXAMPLES=ON
      -DPARQUET_BUILD_EXECUTABLES=ON
      -DARROW_PLASMA=ON
      -DARROW_PROTOBUF_USE_SHARED=ON
      -DARROW_PYTHON=ON
      -DARROW_WITH_BZ2=ON
      -DARROW_WITH_ZLIB=ON
      -DARROW_WITH_ZSTD=ON
      -DARROW_WITH_LZ4=ON
      -DARROW_WITH_SNAPPY=ON
      -DARROW_WITH_BROTLI=ON
      -DARROW_INSTALL_NAME_RPATH=OFF
      -DARROW_BUILD_EXAMPLES=ON
      -DPYTHON_EXECUTABLE=#{Formula["python@3.9"].bin/"python3"}
    ]

    mkdir "build" do
      system "cmake", "../cpp", *std_cmake_args, *args
      system "make"
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include "arrow/api.h"
      int main(void) {
        arrow::int64();
        return 0;
      }
    EOS
    system ENV.cxx, "test.cpp", "-std=c++11", "-I#{include}", "-L#{lib}", "-larrow", "-o", "test"
    system "./test"
  end
end
