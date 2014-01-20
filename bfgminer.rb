require 'formula'

class Bfgminer < Formula
    homepage 'https://github.com/luke-jr/bfgminer'
    head 'https://github.com/luke-jr/bfgminer.git', :branch => 'bfgminer'
    url 'https://github.com/luke-jr/bfgminer.git', :tag => 'bfgminer-3.10.0'
    version '3.10.0'
    
    depends_on 'autoconf' => :build
    depends_on 'automake' => :build
    depends_on 'libtool' => :build
    depends_on 'pkg-config' => :build
    depends_on 'uthash' => :build
    depends_on 'curl'
    depends_on 'jansson'
    depends_on 'libusb'
    # depends_on 'libmicrohttpd'
    depends_on 'libevent'

    option 'with-cpumining', "Enable CPU mining"

    def install
        system "./autogen.sh"

        args = [
          "--disable-debug",
          "--disable-dependency-tracking",
          "--prefix=#{prefix}",
          "PKG_CONFIG_PATH=#{HOMEBREW_PREFIX}/opt/curl/lib/pkgconfig:#{HOMEBREW_PREFIX}/opt/jansson/lib/pkgconfig:#{HOMEBREW_PREFIX}/opt/libusb/lib/pkgconfig",
          "--enable-scrypt",
          "--enable-opencl"
        ]

        args << "--enable-cpumining" if build.include? 'with-cpumining'

        system "./configure", *args
        system "make", "install"
    end

    test do
        system "bfgminer"
    end
end